require 'spec_helper'

describe Projects::DeploymentsController do
  include ApiHelpers

  let(:user) { create(:user) }
  let(:project) { create(:empty_project) }
  let(:environment) { create(:environment, name: 'production', project: project) }

  before do
    project.team << [user, :master]

    sign_in(user)
  end

  describe 'GET #index' do
    it 'returns list of deployments from last 8 hours' do
      create(:deployment, environment: environment, created_at: 9.hours.ago)
      create(:deployment, environment: environment, created_at: 7.hours.ago)
      create(:deployment, environment: environment)

      get :index, deployment_params(after: 8.hours.ago)

      expect(response).to be_ok

      expect(json_response['deployments'].count).to eq(2)
    end

    it 'returns a list with deployments information' do
      create(:deployment, environment: environment)

      get :index, deployment_params

      expect(response).to be_ok
      expect(response).to match_response_schema('deployments')
    end
  end

  describe 'GET #metrics' do
    let(:deployment) { create(:deployment, project: project, environment: environment) }

    before do
      allow(controller).to receive(:deployment).and_return(deployment)
    end

    context 'when environment has no metrics' do
      before do
        expect(deployment).to receive(:metrics).and_return(nil)
      end

      it 'returns a empty response 204 resposne' do
        get :metrics, deployment_params(id: deployment.id)
        expect(response).to have_http_status(204)
        expect(response.body).to eq('')
      end
    end

    context 'when environment has some metrics' do
      let(:empty_metrics) do
        {
          success: true,
          metrics: {},
          last_update: 42
        }
      end

      before do
        expect(deployment).to receive(:metrics).and_return(empty_metrics)
      end

      it 'returns a metrics JSON document' do
        get :metrics, deployment_params(id: deployment.id)

        expect(response).to be_ok
        expect(json_response['success']).to be(true)
        expect(json_response['metrics']).to eq({})
        expect(json_response['last_update']).to eq(42)
      end
    end
  end

  def deployment_params(opts = {})
    opts.reverse_merge(namespace_id: project.namespace,
                       project_id: project,
                       environment_id: environment.id)
  end
end
