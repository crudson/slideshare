require 'hashie'
require 'httparty'
require 'openssl'
require 'time'

module SlideShare
  class Client
    include HTTParty

    debug_output

    attr_accessor :configuration

    BASE_URL = "https://www.slideshare.net/api/2/"

    def initialize config_file = nil
      @configuration = Configuration.new
      configuration.load_from(config_file) if config_file
    end

    def config_valid?
      raise "Please set configuration" unless @configuration.valid?
    end

    # Get options hash for a new call
    def http_options time = nil
      config_valid?
      ts = (time || Time.new).to_i.to_s
      digest = OpenSSL::Digest::SHA1.hexdigest(@configuration.shared_secret + ts)
      {
        api_key: @configuration.api_key,
        ts: ts,
        hash: digest
      }
    end

    def get_url method
      "#{self.class::BASE_URL}#{method}"
    end


    # args:
    #  slideshow_id: id of the slideshow to be fetched.
    # options:
    # slideshow_url: URL of the slideshow to be fetched.
    #                This is required if slideshow_id is not set.
    #                If both are set, slideshow_id takes precedence.
    #      username: username of the requesting user
    #      password: password of the requesting user
    #  exclude_tags: Exclude tags from the detailed information. 1 to exclude.
    #      detailed: Whether or not to include optional information.
    #                1 to include, 0 (default) for basic information.
    def get_slideshow slideshow_id, options = {}
      do_request 'get_slideshow', options.merge(q: q)
    end

    # args:
    #  tag: tag name
    # options:
    #    limit: specify number of items to return
    #   offset: specify offset
    # detailed: Whether or not to include optional information.
    #           1 to include, 0 (default) for basic information.
    def get_slideshows_by_tag tag, options = {}
      do_request 'get_slideshows_by_tag', options.merge(tag: tag)
    end

    # args:
    #  group_name: Group name (as returned in QueryName element in get_user_groups method)
    # options:
    #     limit: specify number of items to return
    #    offset: specify offset
    #  detailed: Whether or not to include optional information.
    #            1 to include, 0 (default) for basic information.
    def get_slideshows_by_group group_name, options = {}
      do_request 'get_slideshows_by_group', options.merge(group_name: group_name)
    end

    # args:
    #  username_for: username of owner of slideshows
    # options:
    #        username: username of the requesting user
    #        password: password of the requesting user
    #           limit: specify number of items to return
    #          offset: specify offset
    #        detailed: Whether or not to include optional information.
    #                  1 to include, 0 (default) for basic information.
    # get_unconverted: Whether or not to include unconverted slideshows.
    #                  1 to include them, 0 (default) otherwise.
    def get_slideshows_by_user username_for, options = {}
      do_request 'get_slideshows_by_user', options.merge(username_for: username_for)
    end

    # args:
    #  q: the query string
    # options:
    #             page: The page number of the results (works in conjunction with items_per_page),
    #                   default is 1
    #   items_per_page: Number of results to return per page,
    #                   default is 12
    #             lang: Language of slideshows
    #                   (default is English, 'en')
    #                   ('**':All,'es':Spanish,'pt':Portuguese,'fr':French,'it':Italian,
    #                    'nl':Dutch, 'de':German,'zh':Chinese,'ja':Japanese,'ko':Korean,
    #                    'ro':Romanian, '!!':Other)
    #             sort: Sort order
    #                   (default is 'relevance')
    #                   ('mostviewed','mostdownloaded','latest')
    #      upload_date: The time period you want to restrict your search to. 'week' would
    #                   restrict to the last week.
    #                   (default is 'any')
    #                   ('week', 'month', 'year')
    #             what: What type of search. If not set, text search is used. 'tag' is the other option.
    #         download: Slideshows that are available to download; Set to '0' to do this,
    #                   otherwise default is all slideshows.
    #       fileformat: File format to search for.
    #                   Default is "all".
    #                   ('pdf':PDF,'ppt':PowerPoint,'odp':Open Office,
    #                    'pps':PowerPoint Slideshow,'pot':PowerPoint template)
    #        file_type: File type to search for.
    #                   Default is "all".
    #                   ('presentations', 'documents','webinars','videos')
    #               cc: Set to '1' to retrieve results under the Creative Commons license.
    #                   Default is '0'
    #         cc_adapt: Set to '1' for results under Creative Commons that allow adaption, modification.
    #                   Default is '0'
    # cc_commercialSet: to '1' to retrieve results with the commercial Creative Commons license.
    #                   Default is '0'
    #         detailed: Whether or not to include optional information.
    #                   1 to include, 0 (default) for basic information.
    def search_slideshows q, options = {}
      do_request 'search_slideshows', option.merge(q: q)
    end

    # args:
    #  username_for: username of user whose groups are being requested
    # options:
    #  username: username of the requesting user
    #  password: password of the requesting user
    def get_user_groups username_for, options = {}
      do_request 'get_user_groups', options.merge(username_for: username_for)
    end

    # args:
    #  username_for: username of user whose Favorites are being requested
    def get_user_favorites username_for
      do_request 'get_user_favorites', username_for: username_for
    end

    # args:
    #  username_for: username of user whose Contacts are being requested
    # options:
    #   limit: specify number of items to return
    #  offset: specify offset
    def get_user_contacts username_for, options = {}
      do_request 'get_user_contacts', option.merge(username_for: username_for)
    end

    # args:
    #  username: username of the requesting user
    #  password: password of the requesting user
    def get_user_tags username, password
      do_request 'get_user_tags', username: username, password: password
    end

    # args:
    #      username: username of the requesting user
    #      password: password of the requesting user
    #  slideshow_id: slideshow ID
    # options:
    #         slideshow_title: text
    #   slideshow_description: text
    #          slideshow_tags: text
    #  make_slideshow_private: Should be Y if you want to make the slideshow private.
    #                          If this is not set, following tags will not be considered
    #     generate_secret_url: Generate a secret URL for the slideshow.
    #                          Requires make_slideshow_private to be Y
    def edit_slideshow username, password, slideshow_id, options = {}
      do_request 'edit_slideshow', options.merge(username: username, password: password,
                                                 slideshow_id: slideshow_id)
    end

    # args:
    #      username: username of the requesting user
    #      password: password of the requesting user
    #  slideshow_id: slideshow ID
    def delete_slideshow username, password, slideshow_id
      do_request 'delete_slideshow', username: username, password: password, slideshow_id: slideshow_id
    end

    # URL https://www.slideshare.net/api/2/upload_slideshow
    # args:
    #           username: username of the requesting user
    #           password: password of the requesting user
    #    slideshow_title: slideshow's title
    # options:
    #       slideshow_srcfile: slideshow file (requires HTTPS POST) -OR-
    #              upload_url: string containing an url pointing to the power point file
    #
    #   slideshow_description: description
    #          slideshow_tags: tags should be comma separated
    #         make_src_public: Y if you want users to be able to download the ppt file, N otherwise.
    #                          Default is Y
    #  make_slideshow_private: Should be Y if you want to make the slideshow private.
    #                          If this is not set, following tags will not be considered
    #     generate_secret_url: Generate a secret URL for the slideshow.
    #                          Requires make_slideshow_private to be Y
    #            allow_embeds: Sets if other websites should be allowed to embed the slideshow.
    #                          Requires make_slideshow_private to be Y
    #     share_with_contacts: Sets if your contacts on SlideShare can view the slideshow.
    #                          Requires make_slideshow_private to be Y
    def upload_slideshow username, password, slideshow_title, options = {}
      do_request 'upload_slideshow', options.merge(username: username, password: password,
                                                   slideshow_title: slideshow_title)
    end

    # args:
    #      username: username of the requesting user
    #      password: password of the requesting user
    #  slideshow_id: the slideshow to be favorited
    def add_favorite username, password, slideshow_id
      do_request 'add_favorite', username: username, password: password, slideshow_id: slideshow_id
    end

    # args:
    #      username: of the requesting user
    #      password: password of the requesting user
    #  slideshow_id: Slideshow which would be favorited
    def check_favorite username, password, slideshow_id
      do_request 'check_favorite', username: username, password: password, slideshow_id: slideshow_id
    end

    # args:
    #  username: username of the requesting user
    #  password: password of the requesting user
    def get_user_campaigns username, password
      do_request 'get_user_campaigns', username: username, password: password
    end

    # args:
    #  username: username of the requesting user
    #  password: password of the requesting user
    # options:
    #  begin: only get leads collected after this UTC date: YYYYMMDDHHMM
    #    end: only get leads collected before this UTC date: YYYYMMDDHHMM
    def get_user_leads username, password, options = {}
      do_request 'get_user_leads', options.merge(username: username, password: password)
    end

    # args:
    #     username: username of the requesting user
    #     password: password of the requesting user
    #  campaign_id: campaign_id to select the leads from
    # options:
    #  begin: only get leads collected after this UTC date: YYYYMMDDHHMM
    #    end: only get leads collected before this UTC date: YYYYMMDDHHMM
    def get_user_campaign_leads username, password, campaign_id, options = {}
      do_request 'get_user_campaign_leads', options.merge(username: username, password: password,
                                                          campaign_id: campaign_id)
    end

    private

    def do_request cmd, options
      config_valid?
      url = get_url cmd
      ops = http_options.merge!(options)
      res = self.class.get(url, query: ops)
      self.class.underscore_keys res
      Hashie::Mash.new res
    end

    def self.underscore_keys hash
      hash.keys.each do |k|
        new_k = k.to_s.dup
        new_k.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
        new_k.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        new_k.downcase!
        val = hash.delete k
        hash[new_k] = val
        if val.is_a? Hash
          underscore_keys val
        end
      end
    end
  end
end
