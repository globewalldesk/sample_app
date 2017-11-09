if Rails.env.production?
  CarrierWave.configure do |config|
    # Configuration for MS Azure Blob
    config.azure_storage_account_name = 'startthis'
    config.azure_storage_access_key = ENV['AZURE_ACCESS_KEY']
    # config.azure_storage_blob_host = 'https://startthis.blob.core.windows.net/' # optional
    config.azure_container = 'startthis-main-container'
    # config.asset_host = 'YOUR CDN HOST' # optional
  end
end