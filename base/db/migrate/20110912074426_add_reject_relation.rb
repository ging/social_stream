class AddRejectRelation < ActiveRecord::Migration
  def up
    Actor.all.each do |a|
      Relation::Reject.default_for(a)
    end

    Tie.
      includes(:relation, :contact, :sender).
      merge(Relation.where(:type => 'Relation::Public')).
      each do |t|
        if t.contact.ties_count != 1
          logger.warn "Public contact #{ t.contact_id } has #{ contact.ties_count }, when expecting 1"
        end

        t.update_attribute :relation_id, t.sender.relation_reject.id
      end
  end

  def down
    Tie.
      includes(:relation, :contact).
      merge(Relation.where(:type => 'Relation::Reject')).
      each do |t|
        t.update_attribute :relation_id, t.sender.relation_public.id
      end

    Relation::Reject.destroy_all
  end
end
