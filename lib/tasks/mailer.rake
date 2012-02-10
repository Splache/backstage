namespace :mailer do
  desc "Send an activity report for user"
  task :send_activity_report, [:user_id] => :environment do |t, args|
    args.with_defaults(:user_id => 0)
    
    if args[:user_id] == 0
      users = User.all
    else
      users = [User.find(args[:user_id])]
    end
    
    users.each do |user|
      puts "Sending #{user.name}'s report ..."
      ActivityReport.send_for_user(user)
    end
  end
end