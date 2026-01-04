# Channel for real-time test run updates
# Broadcasts status changes when test cases are executed
class TestRunChannel < ApplicationCable::Channel
  def subscribed
    test_run = TestRun.find(params[:test_run_id])
    stream_for test_run
  end

  def unsubscribed
    # Cleanup when channel is unsubscribed
  end
end
