class Labeling::SKOS::PrefLabel < Labeling::SKOS::Base

  def build_rdf(document, subject)
    subject.Skos.pref_label(target.to_s, :lang => target.language)
  end

  def self.only_one_allowed?
    true
  end
 
end