FactoryBot.define do
  factory :joule_module do
    name { Faker::Lorem.words(number: 3).join(' ') }
    description { Faker::Lorem.sentence }
    exec_cmd { '/path/to/cmd' }
    web_interface { false }
    status { 'running' }
    joule_id { Faker::Number.number(digits: 3).to_i }
  end
end
