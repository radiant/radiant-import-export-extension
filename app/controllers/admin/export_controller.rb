class Admin::ExportController < ApplicationController
  def yaml
    render :text => Exporter.export, :content_type => "text/yaml"
  end
end
