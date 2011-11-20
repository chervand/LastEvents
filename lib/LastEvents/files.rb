module LastEvents
  class Files
    def get_project_path
      root_path = File.dirname(__FILE__ ) + "/../../"
      return root_path.to_s
    end
    
    def save_xml_data(data, file_name)
      path = self.get_project_path + "data/xml/" + file_name.to_s + ".xml"
      #TODO Handle file overwrite
      file = File.new(path, 'w')
      #TODO Change puts to returs
      if file.write(data)
        puts "XML data saved to #{file_name}.xml"
      else
        puts "Write error"
      end
      file.close
      #TODO Handle exceptions
    end
    
    if __FILE__ == $0
      #data = "print\nprint\nprint"
      #LastEvents::Files.new().save_xml_data(data, "file")
    end
  end
end