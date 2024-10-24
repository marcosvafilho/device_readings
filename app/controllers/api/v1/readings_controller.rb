# frozen_string_literal: true

module Api
  module V1
    class ReadingsController < ApplicationController
      rescue_from ActiveMemory::Errors::RecordInvalid do |e|
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def create
        device = Device.find_or_create_by!(id: params[:id])

        reading_params.each do |reading|
          Reading.create!(
            device_id: device.id,
            timestamp: reading[:timestamp],
            count: reading[:count],
            offset: reading[:timestamp][/[+-]\d{2}:\d{2}$/],
            )
        rescue ActiveMemory::Errors::RecordNotUnique
          next
        end

        head :created
      end

      private

      def reading_params
        params.require(:readings).map do |reading|
          reading.permit(:timestamp, :count)
        end
      end
    end
  end
end
