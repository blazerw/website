class AppStore < Hyperloop::Store

  # we would normally use this to init the store, but we need control over when it is initialized
  # receives Hyperloop::Application::Boot do
  #   boot
  # end

  class << self

    def section_stores
      @section_stores
    end

    def loading_error!
      @loading_error = true
    end

    def errors?
      @loading_error
    end

    def version
      @version
    end

    def local_docs?
      @local_docs
    end

    def loaded?
      are_all_stores_loaded?
    end

    private

    def boot version, local_docs
      @version = version
      @section_stores = {}
      @loading_error = false
      @local_docs = local_docs
      mutate.stores_all_loaded false

      # extend HS1Docs if @version == 'hs1'
      extend EdgeDocs if @version == 'edge'

      load_all_docs
    end

    def are_all_stores_loaded?
      @section_stores.each do |section_hash|
        return false unless section_hash[1].loaded?
      end
      true
    end
  end

end
