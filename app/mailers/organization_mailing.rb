class OrganizationMailing < Mailing

  attr_accessible :recipient_ids

  settings_items :recipient_ids, type: Array

  def generate_from
    "#{person.name} <#{source.environment.noreply_email}>"
  end

  def members_scope
    source.members.order(:id)
      .joins("LEFT OUTER JOIN mailing_sents m ON (m.mailing_id = #{id} AND m.person_id = profiles.id)")
      .where("m.person_id" => nil)
  end

  def recipients
    if self.recipient_ids
      members_scope.where id: self.recipient_ids
    else
      members_scope
    end
  end

  def each_recipient
    offset = 0
    limit = 50
    while (people = recipients.offset(offset).limit(limit)).present?
      people.each do |person|
        yield person
      end
      offset = offset + limit
    end
  end

  def signature_message
    _('Sent by community %s.') % source.name
  end

  include Rails.application.routes.url_helpers
  def url
    url_for(source.url)
  end
end
