# frozen_string_literal: true

describe 'MotionHTMLPipeline::Pipeline::AbsoluteSourceFilterTest' do
  AbsoluteSourceFilter = MotionHTMLPipeline::Pipeline::AbsoluteSourceFilter

  before do
    @image_base_url = 'http://assets.example.com'
    @image_subpage_url = 'http://blog.example.com/a/post'
    @options = {
      image_base_url: @image_base_url,
      image_subpage_url: @image_subpage_url
    }
  end

  it 'test_rewrites_root_urls' do
    orig = %(<p><img src="/img.png"></p>)

    expect("<p><img src=\"#{@image_base_url}/img.png\"></p>")
      .to eq AbsoluteSourceFilter.call(orig, @options).to_s
  end

  it 'test_rewrites_relative_urls' do
    orig = %(<p><img src="post/img.png"></p>)

    expect("<p><img src=\"#{@image_subpage_url}/img.png\"></p>")
      .to eq AbsoluteSourceFilter.call(orig, @options).to_s
  end

  it 'test_does_not_rewrite_absolute_urls' do
    orig = %(<p><img src="http://other.example.com/img.png"></p>)
    result = AbsoluteSourceFilter.call(orig, @options).to_s

    expect(result).not_to match(/@image_base_url/)
    expect(result).not_to match(/@@image_subpage_url/)
  end

  it 'test_fails_when_context_is_missing' do
    expect { AbsoluteSourceFilter.call('<img src="img.png">', {}) }.to raise_error(RuntimeError)
    expect { AbsoluteSourceFilter.call('<img src="/img.png">', {}) }.to raise_error(RuntimeError)
  end

  it 'test_tells_you_where_context_is_required' do
    expect { AbsoluteSourceFilter.call('<img src="img.png">', {}) }
      .to raise_error(RuntimeError, 'MotionHTMLPipeline::Pipeline::AbsoluteSourceFilter')

    expect { AbsoluteSourceFilter.call('<img src="/img.png">', {}) }
      .to raise_error(RuntimeError, 'MotionHTMLPipeline::Pipeline::AbsoluteSourceFilter')
  end
end
