describe 'MotionHTMLPipeline::Pipeline::HttpsFilter' do
  HttpsFilter = MotionHTMLPipeline::Pipeline::HttpsFilter

  def filter(html)
    HttpsFilter.to_html(html, @options)
  end

  before do
    @options = { base_url: 'http://github.com' }
  end

  it 'test_http' do
    expect(%(<a href="https://github.com">github.com</a>))
      .to eq filter(%(<a href="http://github.com">github.com</a>))
  end

  it 'test_https' do
    expect(%(<a href="https://github.com">github.com</a>))
      .to eq filter(%(<a href="https://github.com">github.com</a>))
  end

  it 'test_subdomain' do
    expect(%(<a href="http://help.github.com">github.com</a>))
      .to eq filter(%(<a href="http://help.github.com">github.com</a>))
  end

  it 'test_other' do
    expect(%(<a href="http://github.io">github.io</a>))
      .to eq filter(%(<a href="http://github.io">github.io</a>))
  end

  it 'test_uses_http_url_over_base_url' do
    @options = { http_url: 'http://github.com', base_url: 'https://github.com' }

    expect(%(<a href="https://github.com">github.com</a>))
      .to eq filter(%(<a href="http://github.com">github.com</a>))
  end

  it 'test_only_http_url' do
    @options = { http_url: 'http://github.com' }

    expect(%(<a href="https://github.com">github.com</a>))
      .to eq filter(%(<a href="http://github.com">github.com</a>))
  end

  it 'test_validates_http_url' do
    @options.clear

    expect{ filter('') }
      .to raise_error(ArgumentError, 'MotionHTMLPipeline::Pipeline::HttpsFilter: :http_url')
  end
end
