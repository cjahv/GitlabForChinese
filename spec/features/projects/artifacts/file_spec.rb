require 'spec_helper'

feature 'Artifact file', :js, feature: true do
  let(:project) { create(:project, :public) }
  let(:pipeline) { create(:ci_empty_pipeline, project: project, sha: project.commit.sha, ref: 'master') }
  let(:build) { create(:ci_build, :artifacts, pipeline: pipeline) }

  def visit_file(path)
    visit file_namespace_project_build_artifacts_path(project.namespace, project, build, path)
  end

  context 'Text file' do
    before do
      visit_file('other_artifacts_0.1.2/doc_sample.txt')

      wait_for_ajax
    end

    it 'displays an error' do
      aggregate_failures do
        # shows an error message
        expect(page).to have_content('The source could not be displayed because it is stored as a job artifact. You can download it instead.')

        # does not show a viewer switcher
        expect(page).not_to have_selector('.js-blob-viewer-switcher')

        # does not show a copy button
        expect(page).not_to have_selector('.js-copy-blob-source-btn')

        # shows a download button
        expect(page).to have_link('Download')
      end
    end
  end

  context 'JPG file' do
    before do
      visit_file('rails_sample.jpg')

      wait_for_ajax
    end

    it 'displays the blob' do
      aggregate_failures do
        # shows rendered image
        expect(page).to have_selector('.image_file img')

        # does not show a viewer switcher
        expect(page).not_to have_selector('.js-blob-viewer-switcher')

        # does not show a copy button
        expect(page).not_to have_selector('.js-copy-blob-source-btn')

        # shows a download button
        expect(page).to have_link('Download')
      end
    end
  end
end
