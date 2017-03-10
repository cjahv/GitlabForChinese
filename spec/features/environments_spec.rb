require 'spec_helper'

feature 'Environments page', :feature, :js do
  given(:project) { create(:empty_project) }
  given(:user) { create(:user) }
  given(:role) { :developer }

  background do
    project.team << [user, role]
    login_as(user)
  end

  given!(:environment) { }
  given!(:deployment) { }
  given!(:manual) { }

  before do
    visit_environments(project)
  end

  describe 'page tabs' do
    scenario 'shows "Available" and "Stopped" tab with links' do
      expect(page).to have_link('可用的')
      expect(page).to have_link('停止的')
    end
  end

  context 'without environments' do
    scenario 'does show no environments' do
      expect(page).to have_content('You don\'t have any environments right now.')
    end

    scenario 'does show 0 as counter for environments in both tabs' do
      expect(page.find('.js-available-environments-count').text).to eq('0')
      expect(page.find('.js-stopped-environments-count').text).to eq('0')
    end
  end

  describe 'when showing the environment' do
    given(:environment) { create(:environment, project: project) }

    scenario 'does show environment name' do
      expect(page).to have_link(environment.name)
    end

    scenario 'does show number of available and stopped environments' do
      expect(page.find('.js-available-environments-count').text).to eq('1')
      expect(page.find('.js-stopped-environments-count').text).to eq('0')
    end

    context 'without deployments' do
      scenario 'does show no deployments' do
        expect(page).to have_content('No deployments yet')
      end

      context 'for available environment' do
        given(:environment) { create(:environment, project: project, state: :available) }

        scenario 'does not shows stop button' do
          expect(page).not_to have_selector('.stop-env-link')
        end
      end

      context 'for stopped environment' do
        given(:environment) { create(:environment, project: project, state: :stopped) }

        scenario 'does not shows stop button' do
          expect(page).not_to have_selector('.stop-env-link')
        end
      end
    end

    context 'with deployments' do
      given(:project) { create(:project) }

      given(:deployment) do
        create(:deployment, environment: environment,
                            sha: project.commit.id)
      end

      scenario 'does show deployment SHA' do
        expect(page).to have_link(deployment.short_sha)
      end

      scenario 'does show deployment internal id' do
        expect(page).to have_content(deployment.iid)
      end

      context 'with build and manual actions' do
        given(:pipeline) { create(:ci_pipeline, project: project) }
        given(:build) { create(:ci_build, pipeline: pipeline) }

        given(:manual) do
          create(:ci_build, :manual, pipeline: pipeline, name: 'deploy to production')
        end

        given(:deployment) do
          create(:deployment, environment: environment,
                              deployable: build,
                              sha: project.commit.id)
        end

        scenario 'does show a play button' do
          find('.js-dropdown-play-icon-container').click
          expect(page).to have_content(manual.name.humanize)
        end

        scenario 'does allow to play manual action', js: true do
          expect(manual).to be_skipped

          find('.js-dropdown-play-icon-container').click
          expect(page).to have_content(manual.name.humanize)

          expect { click_link(manual.name.humanize) }
            .not_to change { Ci::Pipeline.count }

          expect(manual.reload).to be_pending
        end

        scenario 'does show build name and id' do
          expect(page).to have_link("#{build.name} ##{build.id}")
        end

        scenario 'does not show stop button' do
          expect(page).not_to have_selector('.stop-env-link')
        end

        scenario 'does not show external link button' do
          expect(page).not_to have_css('external-url')
        end

        scenario 'does not show terminal button' do
          expect(page).not_to have_terminal_button
        end

        context 'with external_url' do
          given(:environment) { create(:environment, project: project, external_url: 'https://git.gitlab.com') }
          given(:build) { create(:ci_build, pipeline: pipeline) }
          given(:deployment) { create(:deployment, environment: environment, deployable: build) }

          scenario 'does show an external link button' do
            expect(page).to have_link(nil, href: environment.external_url)
          end
        end

        context 'with stop action' do
          given(:manual) { create(:ci_build, :manual, pipeline: pipeline, name: 'close_app') }
          given(:deployment) { create(:deployment, environment: environment, deployable: build, on_stop: 'close_app') }

          scenario 'does show stop button' do
            expect(page).to have_selector('.stop-env-link')
          end

          scenario 'starts build when stop button clicked' do
            find('.stop-env-link').click

            expect(page).to have_content('close_app')
          end

          context 'for reporter' do
            let(:role) { :reporter }

            scenario 'does not show stop button' do
              expect(page).not_to have_selector('.stop-env-link')
            end
          end
        end

        context 'with terminal' do
          let(:project) { create(:kubernetes_project, :test_repo) }

          context 'for project master' do
            let(:role) { :master }

            scenario 'it shows the terminal button' do
              expect(page).to have_terminal_button
            end
          end

          context 'for developer' do
            let(:role) { :developer }

            scenario 'does not show terminal button' do
              expect(page).not_to have_terminal_button
            end
          end
        end
      end
    end
  end

  scenario 'does have a New environment button' do
    expect(page).to have_link('New environment')
  end

  describe 'when creating a new environment' do
    before do
      visit_environments(project)
    end

    context 'when logged as developer' do
      before do
        click_link 'New environment'
      end

      context 'for valid name' do
        before do
          fill_in('Name', with: 'production')
          click_on 'Save'
        end

        scenario 'does create a new pipeline' do
          expect(page).to have_content('production')
        end
      end

      context 'for invalid name' do
        before do
          fill_in('Name', with: 'name,with,commas')
          click_on 'Save'
        end

        scenario 'does show errors' do
          expect(page).to have_content('Name can contain only letters')
        end
      end
    end

    context 'when logged as reporter' do
      given(:role) { :reporter }

      scenario 'does not have a New environment link' do
        expect(page).not_to have_link('New environment')
      end
    end
  end

  def have_terminal_button
    have_link(nil, href: terminal_namespace_project_environment_path(project.namespace, project, environment))
  end

  def visit_environments(project)
    visit namespace_project_environments_path(project.namespace, project)
  end
end
