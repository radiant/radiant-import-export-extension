require File.dirname(__FILE__) + '/../test_helper'

class ImportExportExtensionTest < Test::Unit::TestCase
  
  # Replace this with your real tests.
  def test_this_extension
    flunk
  end
  
  def test_initialization
    assert_equal File.join(File.expand_path(RADIANT_ROOT), 'vendor', 'extensions', 'import_export'), ImportExportExtension.root
    assert_equal 'Import Export', ImportExportExtension.extension_name
  end
  
end
