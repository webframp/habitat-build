hab_build 'upload-with-url' do
  action :publish
  depot_url 'https://private-depot.example.com/v1/depot'
  origin 'testorigin'
  ignore_failure true
end
