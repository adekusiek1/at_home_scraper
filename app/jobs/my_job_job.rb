class MyJobJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    p "Im called"
  end
end
