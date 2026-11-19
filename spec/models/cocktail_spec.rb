require 'rails_helper'

RSpec.describe Cocktail, type: :model do
  describe 'creator attribution mutual exclusivity' do
    it 'is valid with no creator attribution set (not yet decided)' do
      cocktail = build(:cocktail, creator_user_id: nil, creator_name: nil, creator_unknown: false)
      expect(cocktail).to be_valid
    end

    it 'is valid with only a linked creator_user' do
      creator = create(:user)
      cocktail = build(:cocktail, creator_user_id: creator.id, creator_name: nil, creator_unknown: false)
      expect(cocktail).to be_valid
    end

    it 'is valid with only an external creator_name' do
      cocktail = build(:cocktail, creator_user_id: nil, creator_name: 'Dale DeGroff', creator_unknown: false)
      expect(cocktail).to be_valid
    end

    it 'is valid with only creator_unknown set' do
      cocktail = build(:cocktail, creator_user_id: nil, creator_name: nil, creator_unknown: true)
      expect(cocktail).to be_valid
    end

    it 'is invalid when creator_user_id and creator_name are both set' do
      creator = create(:user)
      cocktail = build(:cocktail, creator_user_id: creator.id, creator_name: 'Dale DeGroff', creator_unknown: false)
      expect(cocktail).not_to be_valid
      expect(cocktail.errors[:base]).to be_present
    end

    it 'is invalid when creator_name and creator_unknown are both set' do
      cocktail = build(:cocktail, creator_user_id: nil, creator_name: 'Dale DeGroff', creator_unknown: true)
      expect(cocktail).not_to be_valid
    end

    it 'is invalid when creator_user_id and creator_unknown are both set' do
      creator = create(:user)
      cocktail = build(:cocktail, creator_user_id: creator.id, creator_name: nil, creator_unknown: true)
      expect(cocktail).not_to be_valid
    end

    it 'enforces the same rule at the database level via a check constraint' do
      creator = create(:user)
      cocktail = build(:cocktail, creator_user_id: creator.id, creator_name: 'Dale DeGroff', creator_unknown: false)
      expect do
        cocktail.save(validate: false)
      end.to raise_error(ActiveRecord::StatementInvalid, /creator_attribution_mutually_exclusive/)
    end
  end

  describe 'creator_name normalization' do
    it 'treats a whitespace-only creator_name as unset, not as a conflicting value' do
      cocktail = build(:cocktail, creator_name: '   ', creator_unknown: true)
      expect(cocktail).to be_valid
      expect(cocktail.creator_name).to be_nil
    end

    it 'does not raise the DB check constraint for a whitespace-only name alongside creator_unknown' do
      cocktail = build(:cocktail, creator_name: '   ', creator_unknown: true)
      expect { cocktail.save! }.not_to raise_error
    end

    it 'trims incidental surrounding whitespace from a genuine external name' do
      cocktail = build(:cocktail, creator_name: '  Dale DeGroff  ')
      cocktail.valid?
      expect(cocktail.creator_name).to eq('Dale DeGroff')
    end
  end

  describe 'creator attribution does not bypass ownership authorization' do
    it 'does not grant the credited creator any ownership/edit relationship over the cocktail' do
      owner = create(:user)
      creator = create(:user)
      cocktail = create(:cocktail, submitted_by: owner, creator_user: creator)

      expect(cocktail.submitted_by).to eq(owner)
      expect(cocktail.submitted_by_id).not_to eq(creator.id)
      # The controller's require_cocktail_owner check is submitted_by_id-based only;
      # this proves the model layer gives it nothing else to accidentally key off.
      expect(cocktail.submitted_by_id).to eq(owner.id)
    end
  end

  describe 'submitted_by (renamed from bartender, B1)' do
    it 'preserves the existing ownership relationship under the new name' do
      owner = create(:user)
      cocktail = create(:cocktail, submitted_by: owner)
      expect(cocktail.submitted_by).to eq(owner)
      expect(cocktail.submitted_by_id).to eq(owner.id)
    end
  end

  describe 'created_cocktails (User reverse association, B1/B2)' do
    it 'lets a user retrieve cocktails they are credited as creator of, independent of submission' do
      creator = create(:user)
      submitter = create(:user)
      cocktail = create(:cocktail, submitted_by: submitter, creator_user: creator)

      expect(creator.created_cocktails).to include(cocktail)
      expect(submitter.created_cocktails).to be_empty
      expect(creator.cocktails).to be_empty # :cocktails is submission/ownership, not authorship
    end

    it 'blocks deleting a user credited as a creator, leaving the account, credit, and cocktail intact' do
      creator = create(:user)
      submitter = create(:user)
      cocktail = create(:cocktail, submitted_by: submitter, creator_user: creator)

      result = creator.destroy

      expect(result).to be false
      expect(creator.errors[:base]).to be_present
      expect(User.find_by(id: creator.id)).to be_present
      expect(Cocktail.find_by(id: cocktail.id)).to be_present
      expect(cocktail.reload.creator_user_id).to eq(creator.id)
    end

    it 'does not block deleting a user with no creator attributions' do
      creator = create(:user)
      expect(creator.destroy).to eq(creator)
    end
  end

  # ai/v1-redesign-plan.md's publication-lifecycle workstream
  # (2026-11-18). These validations fire on *every* save that leaves
  # published_at present, not only the initial draft→published
  # transition — tested directly below.
  describe 'publication readiness' do
    it 'is valid as a draft with no creator attribution and no recipe text at all' do
      # category stays a real, saved association — belongs_to :category
      # requires it unconditionally (a pre-existing constraint, unrelated
      # to and not relaxed by this workstream); everything else may be
      # missing while a draft.
      cocktail = build(:cocktail, name: nil, execution: nil, ingredients: nil, category: create(:category),
                                  creator_user_id: nil, creator_name: nil, creator_unknown: false)
      expect(cocktail).to be_valid
    end

    it 'is invalid to publish without any creator attribution' do
      cocktail = build(:cocktail, published_at: Time.current,
                                  creator_user_id: nil, creator_name: nil, creator_unknown: false)
      expect(cocktail).not_to be_valid
      expect(cocktail.errors[:base]).to be_present
    end

    it 'is invalid to publish without a name' do
      cocktail = build(:cocktail, published_at: Time.current, creator_unknown: true, name: nil)
      expect(cocktail).not_to be_valid
      expect(cocktail.errors[:name]).to be_present
    end

    it 'is invalid to publish without execution, ingredients, or a category' do
      cocktail = build(:cocktail, published_at: Time.current, creator_unknown: true,
                                  execution: nil, ingredients: nil, category: nil)
      expect(cocktail).not_to be_valid
      expect(cocktail.errors[:execution]).to be_present
      expect(cocktail.errors[:ingredients]).to be_present
      expect(cocktail.errors[:category_id]).to be_present
    end

    it 'is valid to publish with attribution and a complete recipe' do
      # category: create(:category) — a plain build(:cocktail) builds
      # (doesn't persist) its associated category too, leaving
      # category_id nil until saved; a real, saved category is needed
      # here since this is specifically testing category_id presence.
      cocktail = build(:cocktail, published_at: Time.current, creator_unknown: true, category: create(:category))
      expect(cocktail).to be_valid
    end

    it 'rejects clearing attribution on an already-published cocktail without unpublishing' do
      cocktail = create(:cocktail, :published, creator_unknown: true)
      cocktail.creator_unknown = false

      expect(cocktail).not_to be_valid
      expect(cocktail.errors[:base]).to be_present
    end

    it 'rejects clearing a required recipe field on an already-published cocktail without unpublishing' do
      cocktail = create(:cocktail, :published, creator_unknown: true)
      cocktail.name = nil

      expect(cocktail).not_to be_valid
      expect(cocktail.errors[:name]).to be_present
    end

    it 'allows clearing attribution and recipe fields in the same save that unpublishes' do
      cocktail = create(:cocktail, :published, creator_unknown: true)

      expect(cocktail.update(published_at: nil, creator_unknown: false, name: nil)).to be(true)
    end

    it 'allows moving between two valid attribution states while remaining published, in one save' do
      creator = create(:user)
      cocktail = create(:cocktail, :published, creator_unknown: true)

      expect(cocktail.update(creator_unknown: false, creator_user_id: creator.id)).to be(true)
      expect(cocktail.reload.creator_user_id).to eq(creator.id)
    end

    it 'rejects re-publishing without attribution after it was cleared while unpublished' do
      cocktail = create(:cocktail, :published, creator_unknown: true)
      cocktail.update!(published_at: nil, creator_unknown: false)

      expect(cocktail.update(published_at: Time.current)).to be(false)
      expect(cocktail.errors[:base]).to be_present
    end
  end
end
