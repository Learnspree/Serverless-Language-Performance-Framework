require 'json'

def emptytestruby(event:, context:)
  {
    statusCode: 200,
    body: {
      message: 'Empty Ruby test Function Completed.'
    }.to_json
  }
end
