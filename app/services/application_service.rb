class ApplicationService
  class << self
    private
      def logger
        @logger ||= Rails.logger
      end
  end

  private
    def logger
      @logger ||= Rails.logger
    end
end
