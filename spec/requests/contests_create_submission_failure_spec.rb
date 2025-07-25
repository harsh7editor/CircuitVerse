# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contests#create_submission save failure", type: :request do
  let(:user)    { create(:user) }
  let(:contest) { create(:contest, status: :live) }
  let(:project) { create(:project, author: user) }

  before { sign_in user; enable_contests! }

  it "re-renders the new_submission form with 422 when save fails" do
    allow_any_instance_of(Submission).to receive(:save).and_return(false)

    post create_submission_path(contest),
         params: { contest_id: contest.id,
                   submission: { project_id: project.id } }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("contest-submission-button")
  end
end
