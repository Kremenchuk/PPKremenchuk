class RemoveRowFromUserAndConstant < ActiveRecord::Migration
  def change
    change_table :constants do |t|
      t.remove :job_okr_ks_02, :job_okr_ks_03, :job_okr_ks_04, :job_okr_pt_01, :job_okr_pt_02
      t.remove :job_okr_pt_03, :job_okr_pt_04, :job_okr_tp_01,  :job_okr_tp_02, :job_okr_tp_03, :job_okr_tp_04
      t.remove :job_okr_tp_05, :job_okr_tp_06, :job_okr_tp_07
      t.rename :job_okr_ks_01, :job_okr_telegek
    end

    change_table :users do |f|
      f.remove :inn, :edrpou, :pp, :svid_nds, :tel, :adr_ur, :adr_fiz, :language
    end
  end
end
