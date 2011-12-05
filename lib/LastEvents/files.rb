module LastEvents
  class Files
    def get_project_path
      root_path = File.dirname(__FILE__ ) + "/../../"
      return root_path.to_s
    end
    
    def get_rdf_data_path(file_name)
      rdf_data_path = get_project_path + "data/rdf/" + file_name
      return rdf_data_path.to_s
    end
    
    def save_xml_data(data, file_name)
      path = self.get_project_path + "data/xml/" + file_name.to_s + ".xml"
      #TODO Handle file overwrite
      file = File.new(path, 'w')
      #TODO Change puts to returs
      if file.write(data)
        return true
      else
        return false
      end
      file.close
      #TODO Handle exceptions
    end

  end
end