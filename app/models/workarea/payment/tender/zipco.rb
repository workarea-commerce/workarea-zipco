module Workarea
  class Payment
    class Tender
      class Zipco < Tender
        field :token, type: String

        def slug
          :zipco
        end
      end
    end
  end
end
