require 'rails_helper'

RSpec.describe Api::V1::ReadingsController, type: :request do
  describe 'POST /api/v1/readings' do
    context 'with valid parameters' do
      let(:device) { Device.create!(id: "readings-controller-1") }

      let(:valid_params) do
        {
          id: device.id,
          readings: [
            { timestamp: '2021-10-10T10:00:00+00:00', count: 10 },
            { timestamp: '2021-10-10T11:00:00+00:00', count: 15 }
          ]
        }
      end

      it 'returns status created' do
        post '/api/v1/readings', params: valid_params

        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      let(:device) { Device.create!(id: "readings-controller-2") }

      let(:invalid_params) do
        {
          id: device.id,
          readings: [
            { timestamp: '', count: 10 },
            { count: 15 }
          ]
        }
      end

      it 'returns status unprocessable entity' do
        post '/api/v1/readings', params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("can't be blank")
      end
    end
  end
end
