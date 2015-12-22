TD::Users.configure do |config|
  config.base_url               = 'http://localhost:9001'
  config.user_url               = '/api/v1/user'
  config.auth_url               = '/api/v1/auth'
  config.application_secret     = 'TDUserToken-CHANGE-ME!'

  # User urls
  config.create                 = '/create'
  config.current                = '/current'
  config.update                 = '/save'
  config.filter                 = '/find'
  config.add_contact            = '/contact/create/userId/%s'
  config.all_contacts           = '/contact/list/userId/%s'
  config.find_contact           = '/contact/load/userId/%s/contactId/%s'
  config.update_contact         = '/contact/update/userId/%s/contactId/%s'
  config.delete_contact         = '/contact/delete/userId/%s/contactId/%s'
  config.add_address            = '/address/create/userId/%s'
  config.all_addresses          = '/address/list/userId/%s'
  config.find_address           = '/address/load/userId/%s/addressId/%s'
  config.update_address         = '/address/update/userId/%s/addressId/%s'
  config.delete_address         = '/address/delete/userId/%s/addressId/%s'
  config.add_relation           = '/relation/create'
  config.all_relations          = '/relation/list/userId/%s'

  # Auth urls
  config.sign_up                = '/local/signup'
  config.log_in                 = '/local/login'
  config.log_out                = '/logout/userId/%s'
  config.facebook               = '/facebook'
  config.verify                 = '/verify'
  config.verify_request         = '/verify-request/userId/%s'
  config.reset_password_request = '/password/reset-request'
  config.reset_password         = '/password/reset'
  config.update_password        = '/password/update/userId/%s'
  config.update_email           = '/email/update/userId/%s'
end
