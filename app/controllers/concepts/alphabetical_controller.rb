# encoding: UTF-8

# Copyright 2011-2013 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'concerns/dataset_initialization'

class Concepts::AlphabeticalController < ConceptsController
  include DatasetInitialization

  def index
    authorize! :read, Concept::Base

    redirect_to(url_for prefix: 'a') unless params[:prefix]

    # only initilaize dataset if dataset param is set
    # prevent obsolet http request when using matches widget
    datasets = params[:dataset] ? init_datasets : []

    @letters = Label::Base.select("DISTINCT UPPER(SUBSTR(value, 1, 1)) AS letter")
                          .order("letter").map(&:letter)

    if dataset = datasets.detect { |dataset| dataset.name == params[:dataset] }
      query = params[:prefix].mb_chars.downcase.to_s
      @search_results = dataset.alphabetical_search(query, I18n.locale) || []
      @search_results = Kaminari.paginate_array(@search_results).page(params[:page])
    else
      @search_results = find_labelings

      # When in single query mode, AR handles ALL includes to be loaded by that
      # one query. We don't want that! So let's do it manually :-)
      includes = Iqvoc::Concept.base_class.default_includes
      if Iqvoc::Concept.note_classes.include?(Note::SKOS::Definition)
        includes << Note::SKOS::Definition.name.to_relation_name
      end
      ActiveRecord::Associations::Preloader.new.preload(@search_results, owner: includes)

      @search_results.to_a.map! { |pl| AlphabeticalSearchResult.new(pl) }
    end

    respond_to do |format|
      format.html { render :index, layout: with_layout? }
    end
  end

  protected

  def find_labelings
    query = params[:prefix].mb_chars.downcase.to_s

    Iqvoc::Concept.pref_labeling_class.
      concept_published.
      concept_not_expired.
      label_begins_with(query).
      by_label_language(I18n.locale).
      includes(:target).
      order("LOWER(#{Label::Base.table_name}.value)").
      joins(:owner).
      where(concepts: { type: Iqvoc::Concept.base_class_name }).
      references(:concepts, :labels, :labelings).
      page(params[:page])
  end
end
