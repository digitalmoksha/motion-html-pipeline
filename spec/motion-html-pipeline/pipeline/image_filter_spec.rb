# frozen_string_literal: true

describe 'MotionHTMLPipeline::Pipeline::ImageFilterTest' do
  ImageFilter = MotionHTMLPipeline::Pipeline::ImageFilter

  def filter(html)
    ImageFilter.to_html(html)
  end

  it 'test_jpg' do
    expect(%(<img src="http://example.com/test.jpg" alt=""/>))
      .to eq filter(%(http://example.com/test.jpg))
  end

  it 'test_jpeg' do
    expect(%(<img src="http://example.com/test.jpeg" alt=""/>))
      .to eq filter(%(http://example.com/test.jpeg))
  end

  it 'test_bmp' do
    expect(%(<img src="http://example.com/test.bmp" alt=""/>))
      .to eq filter(%(http://example.com/test.bmp))
  end

  it 'test_gif' do
    expect(%(<img src="http://example.com/test.gif" alt=""/>))
      .to eq filter(%(http://example.com/test.gif))
  end

  it 'test_png' do
    expect(%(<img src="http://example.com/test.png" alt=""/>))
      .to eq filter(%(http://example.com/test.png))
  end

  it 'test_https_url' do
    expect(%(<img src="https://example.com/test.png" alt=""/>))
      .to eq filter(%(https://example.com/test.png))
  end
end
