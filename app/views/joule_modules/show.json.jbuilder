json.data do
  json.array! @joule_modules do |m|
    json.extract! m, *JouleModule.json_keys
    json.url @url_template % [m.id]
  end
end

json.partial! "helpers/messages", service: @service