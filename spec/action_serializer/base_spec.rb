require "spec_helper"
require "./lib/action_serializers"
require "active_support/all"

describe ActionSerializers::Base do
  let(:klass) { Class.new(ActionSerializers::Base) }
  let(:generic_serializer) { double(:serializer, object: nil) }
  let(:instantiated_serializer) { double(:instantiated_serializer) }

  before do
    stub_const("BananaSerializer", generic_serializer)
    stub_const("ActionSerializers::ReuseArraySerializer", generic_serializer)
    allow(generic_serializer).to receive(:new) { instantiated_serializer }
    allow(instantiated_serializer).to receive(:as_json) { { banana: :stand } }
    ActionSerializers.configuration = ActionSerializers::Configuration.new
  end

  describe "ClassMethods" do
    describe "#resource" do
      subject { klass._resource }

      context "key given" do
        let(:params) { [:banana] }

        before { klass.resource(*params) }

        it "should set _resources" do
          expect(subject).to be_a(ActionSerializers::ResourceConfiguration)
        end
      end

      context "serializer given as second argument" do
        let(:params) { [:banana, BananaSerializer] }

        it "should set _resources" do
          expect(ActionSerializers::ResourceConfiguration).to receive(:new).with(:banana, serializer: BananaSerializer)
          klass.resource(*params)
        end
      end

      context "no serializer for given key" do
        let(:params) { [:apple] }

        it "it should raise error" do
          expect { klass.resource(*params) }.to raise_error
        end
      end

      context "multiple resources" do
        let(:params) { [:banana] }
        let(:second_params) { [:rotten_bananas, { serializer: BananaSerializer }] }

        before { klass.resource(*params) }

        it "it should raise error" do
          expect { klass.resource(*second_params) }.to raise_error
        end
      end
    end

    describe "#linked" do
      subject { klass._linked }

      context "given key" do
        let(:params) { [:banana] }

        before { klass.linked(*params) }

        it "should add resource to @_linked" do
          expect(subject[0]).to be_a(ActionSerializers::LinkedResourceConfiguration)
        end
      end

      context "given key and serializer" do
        let(:params) { [ripe_bananas: { serializer: BananaSerializer }] }

        before { klass.linked(*params) }

        it "should add resource to @_linked" do
          expect(subject[0]).to be_a(ActionSerializers::LinkedResourceConfiguration)
        end
      end

      context "multiple keys" do
        let(:params) { [:banana, ripe_bananas: { serializer: BananaSerializer }] }

        before { klass.linked(*params) }

        it "should add resources to @_linked" do
        end
      end

      context "multiple calls" do
        let(:params) { [:banana] }
        let(:second_params) { [{ rotten_bananas: { serializer: BananaSerializer } }] }

        before do
          klass.linked(*params)
          klass.linked(*second_params)
        end

        it "should add resources to @_linked" do
          expect(subject.length).to be(2)
          expect(subject[0]).to be_a(ActionSerializers::LinkedResourceConfiguration)
          expect(subject[1]).to be_a(ActionSerializers::LinkedResourceConfiguration)
        end
      end
    end

    describe "#meta" do
      subject { klass._meta }

      context "given key" do
        let(:params) { [:nutritional_guide] }

        it "should add meta resource" do
          klass.meta(*params)
          is_expected.to include(:nutritional_guide)
        end
      end

      context "given key and lambda" do
        let(:params) { [:nutritional_guide, -> { { eat: [:vegtables, :meat], devour: [:cake] } }] }

        it "should add meta resource" do
          klass.meta(*params)
          is_expected.to include(:nutritional_guide)
        end
      end
    end
  end

  describe "#serialize" do
    let(:brand) { double(:brand, name: "Del Monte") }
    let(:banana) { double(:banana, brands: [brand]) }
    let(:options) { {} }

    before do
      stub_const("BrandSerializer", generic_serializer)
    end

    subject { klass.new(banana, options).serialize }

    after { pp(is_expected) }

    context "when resource, linked and metadata resources defined" do
      before do
        klass.resource(:banana)
        klass.linked(:brands)
        klass.meta(:version, -> { "1.2.1" })
      end

      it "should serialize resource in document root" do
        is_expected.to include(:banana)
      end

      it "should serializer linked resources under 'linked' key" do
        is_expected.to include(:linked)
      end

      it "should not include metadata" do
        is_expected.to include(:meta)
      end
    end

    context "when resource, linked resources defined" do
      before do
        klass.resource(:banana)
        klass.linked(:brands)
      end

      it "should serialize resource in document root" do
        is_expected.to include(:banana)
      end

      it "should serializer linked resources under 'linked' key" do
        is_expected.to include(:linked)
      end

      it "should not include metadata" do
        is_expected.to_not include(:meta)
      end
    end

    context "when resource defined" do
      before do
        klass.resource(:banana)
      end

      it "should serialize resource in document root" do
        is_expected.to include(:banana)
      end

      it "should serializer linked resources under 'linked' key" do
        is_expected.to_not include(:linked)
      end

      it "should not include metadata" do
        is_expected.to_not include(:meta)
      end
    end

    context "when global metadata included" do
      before do
        klass.resource(:banana)
        ActionSerializers.configure { |config|
          config.global_metadata = { nutritional_guide: { top: :candy } } }
      end

      it "should not include metadata" do
        is_expected.to include(:meta)
      end
    end

    context "when linked resource included in options" do
      let(:brands) { [brand] }
      let(:banana) { double(:banana) }
      let(:options) { { brands: brands } }

      before do
        klass.resource(:banana)
        klass.linked(:brands)
      end

      it "should serializer linked resources under 'linked' key" do
        is_expected.to include(:linked)
      end
    end
  end

end
