# frozen_string_literal: true

describe 'MotionHTMLPipeline::Pipeline::ImageMaxWidthFilterTest' do
  def filter(html)
    MotionHTMLPipeline::Pipeline::ImageMaxWidthFilter.call(html)
  end

  def parse(html)
    MotionHTMLPipeline::DocumentFragment.parse(html)
  end

  it 'test_rewrites_image_style_tags' do
    body = "<p>Screenshot: <img src='screenshot.png'></p>"
    doc  = parse(body)

    res = filter(doc)

    expect('<p>Screenshot: <a href="screenshot.png" target="_blank"><img src="screenshot.png" style="max-width:100%;"></a></p>')
      .to eq res.to_html
  end

  it 'test_leaves_existing_image_style_tags_alone' do
    body = "<p><img src='screenshot.png' style='width:100px;'></p>"
    doc  = parse(body)

    res = filter(doc)

    expect('<p><img src="screenshot.png" style="width:100px;"></p>')
      .to eq res.to_html
  end

  it 'test_links_to_image' do
    body = "<p>Screenshot: <img src='screenshot.png'></p>"
    doc  = parse(body)

    res = filter(doc)

    expect('<p>Screenshot: <a href="screenshot.png" target="_blank"><img src="screenshot.png" style="max-width:100%;"></a></p>')
      .to eq res.to_html
  end

  it 'test_doesnt_link_to_image_when_already_linked' do
    body = "<p>Screenshot: <a href='blah.png'><img src='screenshot.png'></a></p>"
    doc  = parse(body)

    res = filter(doc)

    expect('<p>Screenshot: <a href="blah.png"><img src="screenshot.png" style="max-width:100%;"></a></p>')
      .to eq res.to_html
  end

  it 'test_doesnt_screw_up_inlined_images' do
    body = "<p>Screenshot <img src='screenshot.png'>, yes, this is a <b>screenshot</b> indeed.</p>"
    doc  = parse(body)

    expect('<p>Screenshot <a href="screenshot.png" target="_blank"><img src="screenshot.png" style="max-width:100%;"></a>, yes, this is a <b>screenshot</b> indeed.</p>')
      .to eq filter(doc).to_html
  end
end
