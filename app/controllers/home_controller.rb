class HomeController < ApplicationController
  def signin
    @action_params = "redirect##{flash[:redirect_url]}" if flash[:redirect_url]
  end
  def ad_tube
    flash[:redirect_url] = ad_tube_url
  end
  def ads_survey
    survey = ::Ads.survey(params[:url], params[:skipped])
    render json: survey
  end

  def search_results_a2ma
    search_results = Search::A2ma.results.get params[:search_results_id]
    render json: search_results
  end

  def search_a2ma
    search_with Search::A2ma do |results|
      json = ActiveSupport::JSON.decode results
      ads = json["ads"].map {|ad| RecursiveOpenStruct.new(ad)}
      search_results_id = request.uuid
      Search::A2ma.results.store search_results_id, results
      render "home/search/a2ma", locals: {ads:ads, search_results_id: search_results_id, keyword:params[:keyword]},  layout:false
    end
  end

  def search_yahoo
    search_with Search::Yahoo
  end
  def search_google
    search_with  Search::Google
  end

  def ads_sample
    sample = ::Ads.sample(params[:url])
    render json: sample
  end

  def survey_response
    response = ::Ads.response(params[:url], params[:survey])
    render json: response
  end

  def feedback
    content = "It pays to think like a champion."
    template = render_to_string partial:"plugin/feedback_template", locals: {content:content}
    render json: {success:true, template:template.html_safe}
  end

  private
  def search_with(klass)
    query_params = params.select {|k,v| !["controller", "action"].include?(k) }
    result_page = klass.search(query_params)
    if block_given?
      yield(result_page)
    else
      render text: result_page
    end
  end
end
