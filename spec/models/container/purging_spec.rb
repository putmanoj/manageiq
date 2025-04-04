RSpec.describe Container do
  context "::Purging" do
    context ".purge_queue" do
      before do
        EvmSpecHelper.local_miq_server
      end
      let(:purge_time) { (Time.zone.now + 10).round }

      it "submits to the queue" do
        expect(described_class).to receive(:purge_date).and_return(purge_time)
        described_class.purge_timer

        q = MiqQueue.all
        expect(q.length).to eq(1)
        expect(q.first).to have_attributes(
          :class_name  => described_class.name,
          :method_name => "purge_by_date",
          :args        => [purge_time]
        )
      end
    end

    context ".purge" do
      let(:deleted_date) { 6.months.ago }

      before do
        @old_container        = FactoryBot.create(:container, :deleted_on => deleted_date - 1.day)
        @purge_date_container = FactoryBot.create(:container, :deleted_on => deleted_date)
        @new_container        = FactoryBot.create(:container, :deleted_on => deleted_date + 1.day)
      end

      def assert_unpurged_ids(unpurged_ids)
        expect(described_class.order(:id).pluck(:id)).to eq(Array(unpurged_ids).sort)
      end

      it "purge_date and older" do
        described_class.purge(deleted_date)
        assert_unpurged_ids(@new_container.id)
      end

      it "with a window" do
        described_class.purge(deleted_date, 1)
        assert_unpurged_ids(@new_container.id)
      end

      it "purges associated rows" do
        @old_container.container_env_vars << FactoryBot.create(:container_env_var)
        @old_container.container_port_configs << FactoryBot.create(:container_port_config)
        described_class.purge(deleted_date)
        expect(@old_container.container_env_vars.count).to eq(0)
        expect(@old_container.container_port_configs.count).to eq(0)
      end
    end
  end
end
