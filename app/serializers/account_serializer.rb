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
end
