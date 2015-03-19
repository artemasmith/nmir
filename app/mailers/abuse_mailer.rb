class AbuseMailer < ActionMailer::Base
  default from: "multilisting@multilisting.su"

  def inform(emails, abuse)
    @adv = abuse.advertisement_id
    @path = %Q(http://multilisting.su/entity/#{abuse.advertisement.url})
    @author = true
    @status = abuse.status == 'accepted' ? 'принял' : 'отклонил'
    @mcomment = abuse.moderator_comment || ''
    emails.each_with_index do |email, index|
      @author = false if index == (emails.count - 1)
      mail(to: email, subject: 'жалоба на рекламу')
    end
  end
end