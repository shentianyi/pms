class ApplicationAPI < Grape::API
  content_type :json,'application/json;charset=UTF-8'
  format :json
  prefix :api
  mount V1::Service::ServiceBase
end