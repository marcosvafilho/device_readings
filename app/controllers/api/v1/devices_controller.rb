# frozen_string_literal: true

module Api
  module V1
    class DevicesController < ApplicationController
      rescue_from ActiveMemory::Errors::RecordNotFound do |e|
        render json: { error: e.message }, status: :not_found
      end

      def latest_timestamp
        device = Device.find!(params[:id])

        render json: {
          latest_timestamp: device.latest_timestamp
        }, status: :ok
      end

      def cumulative_count
        device = Device.find!(params[:id])

        render json: {
          cumulative_count: device.cumulative_count
        }, status: :ok
      end
    end
  end
end
