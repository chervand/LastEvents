module LastEvents
  # Provides work with files
  class Files
    # Returns path to the project's root folder
    def get_project_path
      root_path = File.dirname(__FILE__ ) + "/../../"
      return root_path.to_s
    end

    # Returns path to the RDF data folder
    def get_rdf_data_path(file_name)
      rdf_data_path = get_project_path + "data/rdf/" + file_name
      return rdf_data_path.to_s
    end

    # Saves XML data to <file_name>.xml file in data/xml/ folder.
    # Returns true or false
    def save_xml_data(data, file_name)
      path = self.get_project_path + "data/xml/" + file_name.to_s + ".xml"
      file = File.new(path, 'w')
      if file.write(data)
        return true
      else
        return false
      end
      file.close
    end

    # Checks if <file_name>.xml file exists in data/xml/ folder
    def xml_exists(file_name)
      path = self.get_project_path + "data/xml/" + file_name.to_s + ".xml"
      File.exist? path
    end

    # Checks if <file_name>.n3 file exists in data/rdf/ folder
    def rdf_exists(file_name)
      path = self.get_project_path + "data/rdf/" + file_name.to_s + ".n3"
      File.exist? path
    end

  end
end