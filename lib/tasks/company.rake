# Store rake tasks specific to [company]
namespace :company do

  # Migrate [Company]'s data into the new CRM
  namespace :migrate do
    require 'progressbar'

    desc "Run all [company] migration tasks"
    task :all => [:config, :users, :comments, :accounts]

    desc "Import [company] defaults (web user, campaigns, etc)"
    task :config => :environment do
      ## Web User
      user = User.create(
        :username   => 'weblead',
        :password   => '[random hash]',
        :email      => 'weblead@company.com',
        :first_name => 'Company',
        :last_name  => 'Web Lead'
      )
      user.roles = ['user']
      user.save
      
      ## Campaigns
      Campaign.create(
        :user_id   => user.id,
        :name      => 'Website - Contact Us',
        :access    => 'Private',
        :status    => 'started',
        :starts_on => '2011-01-01'
      )
      Campaign.create(
        :user_id   => user.id,
        :name      => 'Website - Requested More Information',
        :access    => 'Private',
        :status    => 'started',
        :starts_on => '2011-01-01'
      )
    end

    desc "Import comments"
    task :comments => :environment do
      ## Comments
      file = File.open("db/comments.txt")
      count = `wc -l db/comments.txt`
      puts "Importing #{count.to_i} Comments..."
      progress = ProgressBar.new('Comments', count.to_i)
      weblead_user = User.find_by_username('weblead')
      file.each do |line|
        attrs = line.split("|")
        if (attrs[0].strip != 'id')
          # Until association, attach all new contacts to admin user
          created_by = User.find_by_username(attrs[6].strip) # Assign the contact to the last person who modified the lead

          comment = Comment.new
          comment.update_attributes(
            :user_id          => !created_by.nil? ? created_by.id : weblead_user.id,
            :commentable_id   => weblead_user.id,
            :commentable_type => 'User',
            :comment          => urlescape(attrs[4].strip),
            :created_at       => attrs[3].strip,
            :updated_at       => !attrs[7].strip.nil? ? attrs[7].strip : attrs[3].strip,
            :state            => 'Collapsed',
            :old_user_id      => attrs[1].strip,
            :old_status       => attrs[2].strip
          )
          progress.inc
        end
      end
      progress.finish
    end

    desc "Import accounts"
    task :accounts => :environment do
      ## Accounts
      file = File.open("db/accounts.txt")
      count = `wc -l db/accounts.txt`
      puts "Importing #{count.to_i} Leads/Accounts..."
      progress = ProgressBar.new('Accounts', count.to_i)
      weblead_user = User.find_by_username('weblead')
      file.each do |line|
        attrs = line.unpack('C*').pack('U*').split("|")
        if (attrs[0].strip != 'id')
          ## Find the correct user or use admin account
          created_by = User.find_by_username(attrs[7].strip) # Assign the contact to the person who created the lead
          updated_by = User.find_by_username(attrs[8].strip) # Assign the contact to the last person who modified the lead

          ## Create Lead
          lead = Lead.new
          lead.update_attributes(
            :old_id     => attrs[0].strip,
            :user_id    => (!updated_by.nil? ? updated_by.id : (!created_by.nil? ? created_by.id : weblead_user.id)),
            :access     => 'Private',
            :company    => !attrs[9].strip.empty? ? attrs[9].strip : nil,
            :first_name => !attrs[10].strip.empty? ? attrs[10].strip : '-', # First name cannot be blank
            :last_name  => !attrs[11].strip.empty? ? attrs[11].strip : '-', # Last name cannot be blank
            :title      => !attrs[12].strip.empty? ? attrs[12].strip : nil,
            :business_address_attributes => {
              :street1      => !attrs[13].strip.empty? ? attrs[13].strip : nil,
              :street2      => !attrs[14].strip.empty? ? attrs[14].strip : nil,
              :city         => !attrs[15].strip.empty? ? attrs[15].strip : nil,
              :state        => !attrs[16].strip.empty? ? attrs[16].strip : nil,
              :zipcode      => !attrs[17].strip.empty? ? attrs[17].strip : nil,
              :country      => !attrs[18].strip.empty? ? attrs[18].strip : country_based_on_state_abbreviation(attrs[16].strip),
              :address_type => 'Business'
            },
            :status     => lead_status_by_id(attrs[1].to_i),
            :source     => !attrs[47].strip.empty? ? attrs[47].strip : 'other',
            :email      => !attrs[37].strip.empty? ? attrs[37].strip : nil,
            :alt_email  => !attrs[38].strip.empty? ? attrs[38].strip : nil,
            :phone      => !attrs[31].strip.empty? ? attrs[31].strip : (!attrs[32].strip.empty? ? attrs[32].strip : nil),
            :mobile     => !attrs[35].strip.empty? ? attrs[35].strip : nil,
            :created_at => attrs[3].strip,
            :created_by => (!created_by.nil? ? created_by.id : weblead_user.id),
            :updated_at => attrs[4].strip,
            :updated_by => (!updated_by.nil? ? updated_by.id : weblead_user.id)
          )

          #-- Testing for errors from the insert above
          if lead.id.to_s.empty?
            puts '----'
            puts attrs[0].strip
            puts (!updated_by.nil? ? updated_by.id : weblead_user.id)
            puts 'Private'
            puts !attrs[9].strip.empty? ? attrs[9].strip : nil
            puts !attrs[10].strip.empty? ? attrs[10].strip : nil
            puts !attrs[11].strip.empty? ? attrs[11].strip : nil
            puts !attrs[12].strip.empty? ? attrs[12].strip : nil
            puts !attrs[13].strip.empty? ? attrs[13].strip : nil
            puts !attrs[14].strip.empty? ? attrs[14].strip : nil
            puts !attrs[15].strip.empty? ? attrs[15].strip : nil
            puts !attrs[16].strip.empty? ? attrs[16].strip : nil
            puts !attrs[17].strip.empty? ? attrs[17].strip : nil
            puts !attrs[18].strip.empty? ? attrs[18].strip : country_based_on_state_abbreviation(attrs[16].strip)
            puts 'Business'
            puts lead_status_by_id(attrs[1].to_i)
            puts !attrs[47].strip.empty? ? attrs[47].strip : 'other'
            puts !attrs[37].strip.empty? ? attrs[37].strip : nil
            puts !attrs[38].strip.empty? ? attrs[38].strip : nil
            puts !attrs[31].strip.empty? ? attrs[31].strip : (!attrs[32].strip.empty? ? attrs[32].strip : nil)
            puts !attrs[35].strip.empty? ? attrs[35].strip : nil
            puts attrs[3].strip
            puts (!created_by.nil? ? created_by.id : weblead_user.id)
            puts attrs[4].strip
            puts (!updated_by.nil? ? updated_by.id : weblead_user.id)
            puts '----'
          end

          ## If lead was converted, then create Account, Contact and Account_Contact
          account = nil # Create and empty account object to use below
          if (attrs[1].to_i == -3 || attrs[1].to_i == -4)
            if !Account.find_by_name(attrs[9].strip).nil?
              account_name = "#{attrs[9].strip} (#{attrs[16].strip})" # Append state abbreviation if the account name alread exists
            else
              account_name = attrs[9].strip
            end
            account = Account.find_by_name(account_name) || Account.new
            account.update_attributes(
              :name            => account_name,
              :user_id         => (!updated_by.nil? ? updated_by.id : (!created_by.nil? ? created_by.id : weblead_user.id)),
              :access          => 'Private',
              :website         => !attrs[39].strip.empty? ? attrs[39].strip : nil,
              :toll_free_phone => !attrs[32].strip.empty? ? attrs[32].strip : nil,
              :phone           => !attrs[31].strip.empty? ? attrs[31].strip : nil,
              :email           => !attrs[37].strip.empty? ? attrs[37].strip : nil,
              :front_end_searchable => true,
              :billing_address_attributes => {
                :street1      => !attrs[13].strip.empty? ? attrs[13].strip : nil,
                :street2      => !attrs[14].strip.empty? ? attrs[14].strip : nil,
                :city         => !attrs[15].strip.empty? ? attrs[15].strip : nil,
                :state        => !attrs[16].strip.empty? ? attrs[16].strip : nil,
                :zipcode      => !attrs[17].strip.empty? ? attrs[17].strip : nil,
                :country      => !attrs[18].strip.empty? ? attrs[18].strip : country_based_on_state_abbreviation(attrs[16].strip),
                :address_type => 'Billing'
              },
              :shipping_address_attributes => {
                :street1      => !attrs[25].strip.empty? ? attrs[25].strip : nil,
                :street2      => !attrs[26].strip.empty? ? attrs[26].strip : nil,
                :city         => !attrs[27].strip.empty? ? attrs[27].strip : nil,
                :state        => !attrs[28].strip.empty? ? attrs[28].strip : nil,
                :zipcode      => !attrs[29].strip.empty? ? attrs[29].strip : nil,
                :country      => !attrs[30].strip.empty? ? attrs[30].strip : country_based_on_state_abbreviation(attrs[28].strip),
                :address_type => 'Shipping'
              },
              :created_at => attrs[3].strip,
              :created_by => (!created_by.nil? ? created_by.id : weblead_user.id),
              :updated_at => attrs[4].strip,
              :updated_by => (!updated_by.nil? ? updated_by.id : weblead_user.id)
            )
            
            # Save Contact
            contact = Contact.new
            contact.update_attributes(
              :user_id      => (!updated_by.nil? ? updated_by.id : (!created_by.nil? ? created_by.id : weblead_user.id)),
              :lead_id      => lead.id,
              :access       => 'Private',
              :first_name   => !attrs[10].strip.empty? ? attrs[10].strip : '-',
              :last_name    => !attrs[11].strip.empty? ? attrs[11].strip : '-',
              :title        => !attrs[12].strip.empty? ? attrs[12].strip : nil,
              :source       => !attrs[47].strip.empty? ? attrs[47].strip : 'other',
              :email        => !attrs[37].strip.empty? ? attrs[37].strip : nil,
              :alt_email    => !attrs[38].strip.empty? ? attrs[38].strip : nil,
              :phone        => !attrs[31].strip.empty? ? attrs[31].strip : (!attrs[32].strip.empty? ? attrs[32].strip : nil),
              :office       => !attrs[32].strip.empty? ? attrs[32].strip : nil,
              :fax          => !attrs[33].strip.empty? ? attrs[33].strip : nil,
              :home         => !attrs[34].strip.empty? ? attrs[34].strip : nil,
              :mobile       => !attrs[35].strip.empty? ? attrs[35].strip : nil,
              :pager        => !attrs[36].strip.empty? ? attrs[36].strip : nil,
              :business_address_attributes => {
                :street1      => !attrs[19].strip.empty? ? attrs[19].strip : nil,
                :street2      => !attrs[20].strip.empty? ? attrs[20].strip : nil,
                :city         => !attrs[21].strip.empty? ? attrs[21].strip : nil,
                :state        => !attrs[22].strip.empty? ? attrs[22].strip : nil,
                :zipcode      => !attrs[23].strip.empty? ? attrs[23].strip : nil,
                :country      => !attrs[24].strip.empty? ? attrs[24].strip : country_based_on_state_abbreviation(attrs[22].strip),
                :address_type => 'Business'
              },
              :created_at => attrs[3].strip,
              :created_by => (!created_by.nil? ? created_by.id : weblead_user.id),
              :updated_at => attrs[4].strip,
              :updated_by => (!updated_by.nil? ? updated_by.id : weblead_user.id)
            )
            
            account.contacts << contact
            account.save
          end

          ## Associate lead comments
          id = type = nil
          if (attrs[1].to_i == -3 || attrs[1].to_i == -4)
            id = !account.nil? ? account.id : lead.id
            type = !account.nil? ? 'Account' : 'Lead'
          else
           id = lead.id
           type = 'Lead'
          end
 
         comments = Comment.find_all_by_old_user_id(attrs[0].strip)
         comments.each do |comment|
           comment.update_attributes(
             :commentable_id => id,
             :commentable_type => type
           )
         end
          progress.inc
        end
      end
      progress.finish
    end

    desc "Import users and dealers"
    task :users => :environment do
      #### users.txt format:
      # Column Headers
      #
      # id
      # username
      # password
      # usertype
      # status
      # adddate
      # editdate
      # adduser
      # edituser
      # company
      # contact_first
      # contact_last
      # contact_title
      # 13 contact_address1
      # 14 contact_address2
      # 15 contact_city
      # 16 contact_state
      # 17 contact_zip
      # 18 contact_country
      # 19 home_address1
      # 20 home_address2
      # 21 home_city
      # 22 home_state
      # 23 home_zip
      # 24 home_country
      # 25 ship_address1
      # 26 ship_address2
      # 27 ship_city
      # 28 ship_state
      # 29 ship_zip
      # 30 ship_country
      # Main
      # Office
      # Fax
      # Home
      # Mobile
      # Pager
      # email1
      # email2
      # website
      ###
      file = File.open("db/users.txt")
      count = `wc -l db/users.txt`
      puts "Importing #{count.to_i} Users..."
      progress = ProgressBar.new('Users', count.to_i)
      weblead_user = User.find_by_username('weblead')
      file.each do |line|
        attrs = line.split("|")
        if (!attrs[1].strip.eql?('username'))
          created_by = User.find_by_username(attrs[7].strip)
          updated_by = User.find_by_username(attrs[8].strip)

          user = User.find_by_username(attrs[1].strip) || User.new #User.find_or_initialize_by_username(attrs[1].strip)
          user.update_attributes(
            :username     => attrs[1].strip,
            :password     => !attrs[2].strip.to_s.empty? ? attrs[2].strip : attrs[1].strip,
            :first_name   => !attrs[10].strip.empty? ? attrs[10].strip : nil,
            :last_name    => !attrs[11].strip.empty? ? attrs[11].strip : nil,
            :title        => !attrs[12].strip.empty? ? attrs[12].strip : nil,
            :company      => !attrs[9].strip.empty? ? attrs[9].strip : nil,
            :email        => !attrs[37].strip.to_s.empty? ? attrs[37].strip : '',
            :phone        => !attrs[31].strip.to_s.empty? ? attrs[31].strip : nil,
            :mobile       => !attrs[35].strip.to_s.empty? ? attrs[35].strip : nil,
            :office       => !attrs[32].strip.to_s.empty? ? attrs[32].strip : nil,
            :fax          => !attrs[33].strip.to_s.empty? ? attrs[33].strip : nil,
            :home         => !attrs[34].strip.to_s.empty? ? attrs[34].strip : nil,
            :pager        => !attrs[36].strip.to_s.empty? ? attrs[36].strip : nil,
            :alt_email    => !attrs[38].strip.to_s.empty? ? attrs[38].strip : nil,
            :website      => !attrs[39].strip.to_s.empty? ? attrs[39].strip : nil,
            :created_at   => !attrs[5].strip.to_s.empty? ? attrs[5].strip : "now()",
            :created_by   => !created_by.nil? ? created_by.id : weblead_user.id,
            :updated_at   => !attrs[6].strip.to_s.empty? ? attrs[6].strip : nil,
            :updated_by   => !updated_by.nil? ? updated_by.id : weblead_user.id,
            :home_address_attributes => {
              :street1      => !attrs[19].strip.to_s.empty? ? attrs[19].strip : nil,
              :street2      => !attrs[20].strip.to_s.empty? ? attrs[20].strip : nil,
              :city         => !attrs[21].strip.to_s.empty? ? attrs[21].strip : nil,
              :state        => !attrs[22].strip.to_s.empty? ? attrs[22].strip : nil,
              :zipcode      => !attrs[23].strip.to_s.empty? ? attrs[23].strip : nil,
              :country      => !attrs[24].strip.to_s.empty? ? correct_country(attrs[24].strip) : nil,
              :address_type => !attrs[19].strip.to_s.empty? ? 'Home' : nil
            }
          )
          user.update_attribute(:suspended_at, attrs[4]) if !attrs[4].to_s.empty?

          ## Admin
          if attrs[3].strip.eql?("Admin") || attrs[3].strip.eql?("Master")
            user.update_attribute(:admin, true) # Mass assignments don't work for :admin because of the attr_protected
            user.roles = ['admin'] if attrs[3].strip.eql?("Admin") # Set the roles_mask
            user.roles = ['dealer'] unless attrs[3].strip.eql?("Admin") # Set the roles_mask
            user.save

          ## Dealer
          else
            user.update_attribute(:admin, false)
            user.roles = ['dealer'] # Set the roles_mask
            user.save

            ## Create the Dealer Account and associate the contact
            company = attrs[9].strip.to_s
            if (!company.empty?)
              dealer = Dealer.find_by_name(company) || Dealer.new
              dealer.update_attributes(
                :name             => company,
                :user_id          => !created_by.nil? ? created_by.id : weblead_user.id,
                :access           => 'Private',
                :website          => !attrs[39].strip.to_s.empty? ? attrs[39].strip : nil,
                :toll_free_phone  => !attrs[32].strip.to_s.empty? ? attrs[32].strip : nil,
                :phone            => !attrs[31].strip.to_s.empty? ? attrs[31].strip : nil,
                :fax              => !attrs[33].strip.to_s.empty? ? attrs[33].strip : nil,
                :email            => !attrs[37].strip.to_s.empty? ? attrs[37].strip : '',
                :deleted_at       => attrs[5] == -1 ? 'NOW()' : nil,
                :created_at       => !attrs[5].strip.to_s.empty? ? attrs[5].strip : 'NOW()',
                :updated_at       => !attrs[6].strip.to_s.empty? ? attrs[6].strip : nil,
                :billing_address_attributes => {
                  :street1      => !attrs[13].strip.to_s.empty? ? attrs[13].strip : nil,
                  :street2      => !attrs[14].strip.to_s.empty? ? attrs[14].strip : nil,
                  :city         => !attrs[15].strip.to_s.empty? ? attrs[15].strip : nil,
                  :state        => !attrs[16].strip.to_s.empty? ? attrs[16].strip : nil,
                  :zipcode      => !attrs[17].strip.to_s.empty? ? attrs[17].strip : nil,
                  :country      => !attrs[18].strip.to_s.empty? ? correct_country(attrs[18].strip) : nil,
                  :address_type => !attrs[13].strip.to_s.empty? ? 'Billing' : nil
                },
                :shipping_address_attributes => {
                  :street1      => !attrs[25].strip.to_s.empty? ? attrs[25].strip : nil,
                  :street2      => !attrs[26].strip.to_s.empty? ? attrs[26].strip : nil,
                  :city         => !attrs[27].strip.to_s.empty? ? attrs[27].strip : nil,
                  :state        => !attrs[28].strip.to_s.empty? ? attrs[28].strip : nil,
                  :zipcode      => !attrs[29].strip.to_s.empty? ? attrs[29].strip : nil,
                  :country      => !attrs[30].strip.to_s.empty? ? correct_country(attrs[30].strip) : nil,
                  :address_type => !attrs[25].strip.to_s.empty? ? 'Shipping' : nil
                }
              )

              # Link dealer and contact (aka user)
              user.update_attribute(:dealer_id, dealer.id)
            end
          end
          progress.inc
        end
      end
      progress.finish
    end

  end

end