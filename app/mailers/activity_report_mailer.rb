class ActivityReportMailer < ActionMailer::Base
  default :from => "production@demarque.com"

  def standard_report(report)
    @report = report
    @recipient = report.recipient
    
    mail(:to => "#{@recipient.name} <#{@recipient.email}>", :subject => "Rapport d'activités - #{@report.total_tasks} tâches")
  end
end