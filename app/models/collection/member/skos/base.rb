# encoding: UTF-8

# Copyright 2012 Hola, S.L.
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

class Collection::Member::SKOS::Base < Collection::Member::Base

  self.rdf_namespace = 'skos'
  self.rdf_predicate = 'member'

  def self.build_from_rdf(rdf_subject, rdf_predicate, rdf_object)
    raise "Labeling::SKOS::Base#build_from_rdf: Subject (#{subject}) must be a Collection." unless rdf_subject.is_a?(Collection::Base)
    raise "Labeling::SKOS::Base#build_from_rdf: Object (#{object}) must be a Collection or Concept." unless rdf_object.is_a?(Collection::Base) or rdf_object.is_a?(Concept::Base)

    member_instance = rdf_subject.send(:members).select{|rel| rel.collection_id == rdf_subject.id || rel.target == rdf_object}.first
    if member_instance.nil?
      member_instance = (rdf_predicate || self).new(:target => rdf_object)
      rdf_subject.send(:members) << member_instance

      if rdf_object.is_a?(Collection::Base)
        rdf_subject.send(:subcollections) << rdf_object
      end
    end

    if rdf_object.send(:collections).select{|coll| coll.id == rdf_subject.id}.empty?
      rdf_object.send(:collections) << rdf_subject
    end
    member_instance
  end
end
