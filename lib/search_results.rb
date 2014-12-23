module SearchResults
  SEARCH_RESULTS_DIR = Rails.root.join('tmp', 'search_results')
  module A2MA
    FILES_DIR = File.join(SEARCH_RESULTS_DIR, 'a2ma')
    def self.init
      FileUtils.mkdir_p(files_dir) unless File.directory?(files_dir)
    end
    def self.get(results_id)
      File.read(file(results_id))
    end
    def self.store(results_id, results)
      File.open(file(results_id), 'w') {|f| begin f.write(results) rescue  puts results.inspect end  }
    end

    private
    def self.file(filename)
      File.join(files_dir, filename)
    end
    def self.files_dir
      FILES_DIR
    end
  end
end
SearchResults::A2MA.init