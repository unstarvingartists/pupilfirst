module Types
  class QueryType < Types::BaseObject
    field :courses, [Types::CourseType], null: false
    field :reviewed_submissions, [Types::ReviewedSubmissionType], null: false do
      argument :course_id, ID, required: true
      argument :page, Int, required: false
    end

    def courses
      CoursesResolver.new(context).collection
    end

    def reviewed_submissions(args)
      ReviewedSubmissionsResolver.new(context).collection(args[:course_id], args[:page])
    end
  end
end
