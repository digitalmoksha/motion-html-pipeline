# frozen_string_literal: true

describe 'MotionHTMLPipeline::PipelineTest' do
  Pipeline = MotionHTMLPipeline::Pipeline

  class TestFilter
    def self.call(input, _context, _result)
      input.reverse
    end
  end

  before do
    @context = {}
    @result_class = Hash
    @pipeline = Pipeline.new [TestFilter], @context, @result_class
  end

  it 'works' do
    expect(true).to be_true
  end

  it 'test_filter_instrumentation' do
    service = MockedInstrumentationService.new
    events = service.subscribe 'call_filter.html_pipeline'
    @pipeline.instrumentation_service = service
    filter(body = 'hello')
    event, payload, res = events.pop

    expect(event).not_to be_nil
    expect('call_filter.html_pipeline').to eq event
    expect(TestFilter.name).to eq payload[:filter]
    expect(@pipeline.class.name).to eq payload[:pipeline]
    expect(body.reverse).to eq payload[:result][:output]
  end

  it 'test_pipeline_instrumentation' do
    service = MockedInstrumentationService.new
    events = service.subscribe 'call_pipeline.html_pipeline'
    @pipeline.instrumentation_service = service
    filter(body = 'hello')
    event, payload, res = events.pop

    expect(event).not_to be_nil
    expect('call_pipeline.html_pipeline').to eq event
    expect(@pipeline.filters.map(&:name)).to eq payload[:filters]
    expect(@pipeline.class.name).to eq payload[:pipeline]
    expect(body.reverse).to eq payload[:result][:output]
  end

  it 'test_default_instrumentation_service' do
    service = 'default'
    Pipeline.default_instrumentation_service = service
    pipeline = Pipeline.new [], @context, @result_class

    expect(service).to eq pipeline.instrumentation_service

    Pipeline.default_instrumentation_service = nil
  end

  it 'test_setup_instrumentation' do
    expect(@pipeline.instrumentation_service).to be_nil

    service = MockedInstrumentationService.new
    events = service.subscribe 'call_pipeline.html_pipeline'
    @pipeline.setup_instrumentation name = 'foo', service

    expect(service).to eq @pipeline.instrumentation_service
    expect(name).to eq @pipeline.instrumentation_name

    filter(body = 'foo')

    event, payload, res = events.pop

    expect(event).not_to be_nil
    expect(name).to eq payload[:pipeline]
    expect(body.reverse).to eq payload[:result][:output]
  end

  def filter(input)
    @pipeline.call(input)
  end
end
