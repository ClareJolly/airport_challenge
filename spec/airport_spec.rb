require "airport"
require 'weather'

describe Airport do
  describe 'check weather' do
    it 'is sunny or stormy' do
      # expect(subject.weather).to eq "sunny"
      expect(subject.weather).to eq('sunny').or(eq('stormy'))
    end
  end
  context('when the weather is sunny') do
    before(:each) do
      allow(subject).to receive(:weather).and_return("sunny")
    end
    describe 'check if not stormy' do
      it 'weather is stormy = false' do
        expect(subject.stormy?).to eq false
      end
    end
    describe 'landing in good weather' do

      it 'instructs a plane to land' do
        plane = Plane.new
        subject.land(plane)
        expect(plane.status?).to eq "land"
      end

      it "returns error if plane already landed" do
        plane = Plane.new
        subject.land(plane)
        expect { subject.land(plane) }.to raise_error(RuntimeError, "plane already landed")
      end

      it 'plane is added to planes array' do
        plane = Plane.new
        subject.land(plane)
        expect(subject.in_hangar(plane)).to eq true
      end

      it 'plane is set as landed' do
        plane = Plane.new
        subject.land(plane)
        expect(plane.status?).to eq "land"
      end

      it 'plane is in hangar at this airport' do
        plane = Plane.new
        subject.land(plane)
        expect(subject.in_hangar(plane)).to eq true
      end
    end
    describe 'take off in good weather' do
      it 'instructs a plane to take off' do
        plane = Plane.new
        subject.land(plane)
        subject.takeoff(plane)
        expect(plane.status?).to eq "air"
      end

      it "returns error if plane already in the air" do
        plane = Plane.new
        expect { subject.takeoff(plane) }.to raise_error(RuntimeError, "plane already in air")
      end

      it "returns error if plane not at this airport" do
        airport2 = Airport.new
        plane = Plane.new(airport2)
        expect { subject.takeoff(plane) }.to raise_error(RuntimeError, "plane not at this airport")
      end

      it 'plane is set as taken off' do
        plane = Plane.new
        subject.land(plane)
        subject.takeoff(plane)
        expect(plane.status?).to eq "air"
      end

      it 'plane is no longer in hangar' do
        plane = Plane.new
        subject.land(plane)
        subject.takeoff(plane)
        expect(subject.in_hangar(plane)).to eq false
      end
    end

    describe 'full?' do

      it 'raises an error when full' do
        # subject.update_weather("sunny")
        subject.capacity.times { subject.land(Plane.new) }
        expect { subject.land(Plane.new) }.to raise_error 'Airport full'
      end
    end
  end

  context('when the weather is stormy') do
    before(:each) do
      # allow(subject).to receive(:stormy?).and_return(true)
      allow(subject).to receive(:weather).and_return("stormy")
    end

    describe 'check if stormy' do
      it 'weather is stormy = true' do
        expect(subject.stormy?).to eq true
      end
    end

    describe 'prevent landing and take off in bad weather' do
      it 'prevents takeoff if stormy' do
        plane = Plane.new
        expect { subject.takeoff(plane) }.to raise_error(RuntimeError, "takeoff not allowed")
      end

      it 'prevents landing if stormy' do
        plane = Plane.new
        expect { subject.land(plane) }.to raise_error(RuntimeError, "landing not allowed")
      end
    end
  end

  describe 'Checks across airport and network' do
    it 'checks capacity of the airport to see if its the default, which is 10' do
      expect(subject.capacity?).to eq Airport::DEFAULT_CAPACITY
    end

    it 'checks to see if there are any landed planes not in an airport' do
      expect(subject.orphan_landed_planes?.empty?).to eq true
    end

    it 'checks to see if there are any flying planes listed as being in an airport' do
      expect(subject.flying_in_airport?.empty?).to eq true
    end
  end

  describe 'overrides' do

    it 'Forces weather update' do
      subject.update_weather("sunny")
      expect(subject.weather).to eq "sunny"
    end

    it 'checks capacity of the airport to 2 when created' do
      airport = Airport.new(2)
      expect(airport.capacity?).to eq 2
    end
  end

end
