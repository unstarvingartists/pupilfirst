# Mails sent out to teams, as a whole.
class StartupMailer < SchoolMailer
  def feedback_as_email(startup_feedback, founder: nil)
    @startup_feedback = startup_feedback
    send_to = founder&.email || startup_feedback.startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    @school = startup_feedback.startup.school

    roadie_mail(
      {
        to: send_to,
        subject: 'Feedback from Team SV',
        **from_options
      },
      roadie_options_for_school
    )
  end

  # Mail sent to startup founders once a connect request is confirmed.
  #
  # @param connect_request [ConnectRequest] Request that was just confirmed
  def connect_request_confirmed(connect_request)
    @connect_request = connect_request
    send_to = connect_request.startup.founders.map { |e| "#{e.fullname} <#{e.email}>" }
    @school = connect_request.startup.school

    roadie_mail(
      {
        to: send_to,
        subject: 'Office hour confirmed.',
        **from_options
      },
      roadie_options_for_school
    )
  end
end
