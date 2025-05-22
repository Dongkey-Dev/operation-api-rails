Pagy Gem Quick Start Guide
Pagy는 Ruby on Rails 및 기타 Ruby 프레임워크에서 사용할 수 있는 고성능, 경량 페이지네이션 라이브러리입니다. 이 가이드는 Pagy를 빠르게 설치하고 설정하며, 기본 및 고급 페이지네이션 기능을 사용하는 방법을 안내합니다.
1. 설치
Bundler 사용
Gemfile에 Pagy를 추가하고, 최신 버전을 명시적으로 지정하여 향후 주요 버전 업데이트로 인한 호환성 문제를 방지하세요.
# Gemfile
gem 'pagy', '~> 9.3' # 최신 버전은 https://rubygems.org/gems/pagy에서 확인

터미널에서 다음 명령어를 실행하여 설치합니다:
bundle install

Bundler 없이 설치
Bundler를 사용하지 않는 경우, 터미널에서 직접 설치합니다:
gem install pagy

데모 실행 (선택)
Pagy를 먼저 테스트해보고 싶다면, 터미널에서 다음 명령어를 실행하여 데모를 확인할 수 있습니다:
pagy demo

그 후 브라우저에서 http://0.0.0.0:8000에 접속하세요.
2. 설정
Rails 애플리케이션
Pagy의 기본 설정을 커스터마이징하려면 config/initializers/pagy.rb 파일을 생성합니다. 이 파일에서 필요한 추가 기능(Extras)을 활성화하거나 기본 설정을 변경할 수 있습니다.
# config/initializers/pagy.rb
require 'pagy/extras/bootstrap' # Bootstrap 스타일 사용 예시
require 'pagy/extras/limit'     # 페이지당 항목 수 선택 기능
Pagy::DEFAULT[:limit] = 25      # 기본 페이지당 항목 수
Pagy::DEFAULT[:overflow] = :empty_page # 오버플로우 처리


참고: Pagy는 불필요한 코드를 로드하지 않으므로, 사용하려는 Extras만 명시적으로 활성화하세요.

Rails 없이 사용
Rails 외의 환경에서는 pagy.rb 설정 파일을 프로젝트의 적절한 디렉토리에 저장하고, 필요한 Extras와 설정을 추가합니다.
3. Backend 설정
기본 설정
컨트롤러에서 Pagy::Backend를 포함하여 Pagy의 페이지네이션 기능을 활성화합니다.
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Pagy::Backend
end

컨트롤러 액션에서 pagy 메서드를 사용하여 컬렉션을 페이지네이션합니다:
# app/controllers/products_controller.rb
class ProductsController < ApplicationController
  def index
    @pagy, @records = pagy(Product.all, limit: 30)
  end
end

검색 및 특수 설정
Searchkick, Elasticsearch 등 검색 프레임워크와 통합하려면 해당 Extra를 활성화하고, 예를 들어 pagy_searchkick 메서드를 사용합니다:
# config/initializers/pagy.rb
Searchkick.extend Pagy::Searchkick

# app/controllers/search_controller.rb
def index
  @pagy, @records = pagy_searchkick(Product.search(params[:q]))
end

4. Frontend 설정 및 렌더링
서버 측 렌더링
뷰에서 페이지네이션 링크를 렌더링하려면 Pagy::Frontend를 헬퍼에 포함합니다:
# app/helpers/application_helper.rb
module ApplicationHelper
  include Pagy::Frontend
end

뷰에서 pagy_nav 헬퍼를 사용하여 페이지네이션 링크를 렌더링합니다:
<!-- app/views/products/index.html.erb -->
<% @records.each do |record| %>
  <p><%= record.name %></p>
<% end %>
<%== pagy_nav(@pagy) %>


참고: <%==는 HTML-safe 출력을 위해 사용됩니다.

CSS 프레임워크 스타일링
Bootstrap, Bulma, Tailwind 등과 통합하려면 해당 Extra를 활성화하고, 예를 들어 pagy_bootstrap_nav를 사용합니다:
<%== pagy_bootstrap_nav(@pagy) %>

JavaScript 프레임워크
JavaScript 프레임워크(예: React, Vue.js)를 사용하는 경우, metadata Extra를 활성화하여 JSON 응답에 페이지네이션 메타데이터를 포함시킬 수 있습니다:
require 'pagy/extras/metadata'

# app/controllers/api/v1/products_controller.rb
def index
  @pagy, @records = pagy(Product.all)
  render json: { records: @records, pagy: pagy_metadata(@pagy) }
end

5. 고급 사용법
페이지당 항목 수 제어
페이지당 항목 수를 설정하려면 limit 변수를 사용합니다:
# config/initializers/pagy.rb
Pagy::DEFAULT[:limit] = 25

또는 컨트롤러에서 개별적으로 설정:
@pagy, @records = pagy(Product.all, limit: 30)

limit Extra를 사용하면 사용자가 페이지당 항목 수를 동적으로 선택할 수 있습니다:
<%== pagy_limit_selector_js(@pagy) %>

페이지 링크 제어
페이지 링크의 수와 위치는 size 변수로 제어합니다:
@pagy = Pagy.new(count: 1000, page: 10, size: 7)
pagy.series #=> [1, :gap, 9, "10", 11, :gap, 100]

첫/마지막 페이지 링크를 제거하려면 ends: false를 설정:
@pagy = Pagy.new(count: 1000, page: 10, size: 7, ends: false)
pagy.series #=> [7, 8, 9, "10", 11, 12, 13]

오버플로우 처리
페이지 범위를 벗어나는 요청은 Pagy::OverflowError를 발생시킵니다. 이를 처리하려면 overflow Extra를 사용하거나, 컨트롤러에서 예외를 처리합니다:
# app/controllers/application_controller.rb
rescue_from Pagy::OverflowError, with: :redirect_to_last_page

private
def redirect_to_last_page(exception)
  redirect_to url_for(page: exception.pagy.last), notice: "Page ##{params[:page]} is overflowing. Showing page #{exception.pagy.last} instead."
end

다국어 지원 (I18n)
Pagy는 기본적으로 다국어를 지원합니다. 사용자 정의 번역을 위해 pagy.rb에서 I18n 설정을 추가합니다:
# config/initializers/pagy.rb
Pagy::I18n.load({ locale: 'ko', filepath: 'path/to/custom-ko.yml' })

최대 페이지 제한
최대 페이지 수를 제한하려면 max_pages 변수를 사용합니다:
@pagy, @records = pagy(Product.all, max_pages: 50, limit: 20)

6. 성능 최적화

Countless Pagination: 전체 레코드 수 쿼리를 생략하여 성능을 향상시킵니다. Pagy::Countless를 사용하세요.
캐싱: 느린 COUNT(*) 쿼리를 캐싱하여 성능을 개선합니다:

def pagy_get_count(collection, _vars)
  cache_key = "pagy-#{collection.model.name}:#{collection.to_sql}"
  Rails.cache.fetch(cache_key, expires_in: 20 * 60) do
    collection.count(:all)
  end
end

7. 테스트
Pagy는 100% 테스트 커버리지를 제공합니다. 기본 설정을 사용한다면 추가 테스트는 필요하지 않습니다. 사용자 정의 메서드를 오버라이드한 경우에만 테스트하세요.
# 테스트 예시
@pagy, @records = pagy(Book.all, limit: 10)
assert_equal 10, @pagy.limit

8. 커스텀 템플릿
Pagy의 기본 헬퍼 대신 사용자 정의 템플릿을 사용할 수 있습니다:
<!-- app/views/shared/_pagy_nav.html.erb -->
<% a = pagy_anchor(@pagy) %>
<nav class="pagy nav" aria-label="Pages">
  <% if @pagy.prev %>
    <%= a.(@pagy.prev, '<', aria_label: 'Previous') %>
  <% else %>
    <a role="link" aria-disabled="true" aria-label="Previous"><</a>
  <% end %>
  <% @pagy.series.each do |item| %>
    <% if item.is_a?(Integer) %>
      <%= a.(item) %>
    <% elsif item.is_a?(String) %>
      <a role="link" aria-disabled="true" aria-current="page" class="current"><%= item %></a>
    <% elsif item == :gap %>
      <a role="link" aria-disabled="true" class="gap">…</a>
    <% end %>
  <% end %>
  <% if @pagy.next %>
    <%= a.(@pagy.next, '>', aria_label: 'Next') %>
  <% else %>
    <a role="link" aria-disabled="true" aria-label="Next">></a>
  <% end %>
</nav>

뷰에서 사용:
<%== render partial: 'shared/pagy_nav', locals: { pagy: @pagy } %>

추가 참고 자료

Pagy 공식 문서
Pagy GitHub 저장소
Extras 문서: https://ddnexus.github.io/pagy/extras/
Pagy AI 지원: 질문이 있을 경우 Pagy 공식 사이트의 AI 챗봇을 활용하세요.

