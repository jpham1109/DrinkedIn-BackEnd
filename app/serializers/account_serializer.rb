# frozen_string_literal: true

# ai/v1-redesign-plan.md's users.email workstream (2026-11-19).
# Kinpour's launch decision: registered accounts are private by
# default. Only ever used for an account's own view of itself — GET
# /me, PATCH /me, and the signup/login response bodies — never for a
# public profile response. UserSerializer itself is unchanged and stays
# email-free; this just adds the one field on top of it. AMS subclasses
# accumulate attributes/associations from the parent, so every existing
# field/association comes along byte-for-byte.
class AccountSerializer < UserSerializer
  attributes :email

  # ai/v1-redesign-plan.md's privacy-first-user-discovery workstream
  # (2026-11-23), Step 1 — overrides UserSerializer's inherited
  # `has_many :followed_users`/`:following_users` reader methods
  # (same override pattern UserSerializer itself already uses for
  # cocktails/likes) to return plain hashes rather than bare Follow
  # records, so AMS renders the array exactly as built here instead of
  # resolving each entry through FollowSerializer. Additive only — the
  # original id/follower_id/followee_id fields are always present and
  # unchanged; callers relying on today's bare shape see no difference.
  #
  # followed_users (self is the follower on every row): nests the
  # followee's identity, but ONLY when the followee passes
  # User.followable — the one side POST /follows' eligibility check
  # (Step 3) actually restricts, and the only side with any real
  # privacy concern. A followee who fails that check (a pre-existing
  # row from before Step 3 ships, or any other legacy state) renders
  # with no `followee` key at all — not a null one — identical to
  # today's shape for that one row.
  #
  # following_users (self is the followee on every row): nests the
  # follower's identity unconditionally. Nothing restricts who may *be*
  # a follower, only who may *be followed* — a follower already
  # voluntarily revealed themselves by choosing to follow, so gating
  # this side would only hide real followers from their own Followers
  # tab with no privacy benefit.
  #
  # Both branches rely on the caller having preloaded via
  # User.with_follow_identities to avoid N+1 — the followable_ids
  # lookup below is a single batched query (object.followed_users.size,
  # not one query per row), proven by this workstream's N+1 spec.
  def followed_users
    follows = object.followed_users
    followable_ids = User.followable.where(id: follows.map(&:followee_id)).ids.to_set

    follows.map do |follow|
      entry = { id: follow.id, follower_id: follow.follower_id, followee_id: follow.followee_id }
      entry[:followee] = BartenderSerializer.new(follow.followee).as_json if followable_ids.include?(follow.followee_id)
      entry
    end
  end

  def following_users
    object.following_users.map do |follow|
      {
        id: follow.id,
        follower_id: follow.follower_id,
        followee_id: follow.followee_id,
        follower: BartenderSerializer.new(follow.follower).as_json,
      }
    end
  end
end
