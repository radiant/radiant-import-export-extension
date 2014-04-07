# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class ImportExportExtension < Radiant::Extension
  version ImportExport::VERSION
  description "Supports more flexible import and export to Radiant databases."
  url "https://github.com/radiant/radiant-import-export-extension"
 
  def activate
  end
  
  def deactivate
  end
  
end