require "rails_helper"

RSpec.describe Api::V1::DevicesController, type: :controller do
  describe "GET #latest_timestamp" do
    context "when the device is found" do
      let(:device) { Device.create!(id: "devices-controller-1") }

      before do
        allow(Device).to receive(:find!).and_return(device)
        allow(device).to receive(:latest_timestamp).and_return(Time.current)
      end

      it "returns the latest timestamp of the device" do
        get :latest_timestamp, params: { id: device.id }

        expect(response).to have_http_status(:ok)

        expect(response.content_type).to include("application/json")
        expect(JSON.parse(response.body)).to eq("latest_timestamp" => device.latest_timestamp.as_json)
      end
    end

    context "when the device is not found" do
      it "returns json with not found status" do
        get :latest_timestamp, params: { id: "non-existent-id" }

        expect(response).to have_http_status(:not_found)

        expect(response.content_type).to include("application/json")
        expect(JSON.parse(response.body)["error"]).to include("Couldn't find Device")
      end
    end
  end

  describe "GET #cumulative_count" do
    context "when the device is found" do
      let(:device) { Device.create!(id: "devices-controller-2") }

      before do
        allow(Device).to receive(:find!).and_return(device)
        allow(device).to receive(:cumulative_count).and_return(10)
      end

      it "returns the cumulative count of the device" do
        get :cumulative_count, params: { id: device.id }

        expect(response).to have_http_status(:ok)

        expect(response.content_type).to include("application/json")
        expect(JSON.parse(response.body)).to eq("cumulative_count" => device.cumulative_count)
      end
    end

    context "when the device is not found" do
      it "returns json with not found status" do
        get :cumulative_count, params: { id: "non-existent-id" }

        expect(response).to have_http_status(:not_found)

        expect(response.content_type).to include("application/json")
        expect(JSON.parse(response.body)["error"]).to include("Couldn't find Device")
      end
    end
  end
end
