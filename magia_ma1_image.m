function parametric_images = magia_ma1_image(pet_filename,input,frames,brainmask_filename,start_time,end_time,outputdir)

V = spm_vol(pet_filename);
pet_img = spm_read_vols(V);
pet_img = reshape(pet_img,[prod(V(1).dim(1:3)) size(V,1)])';
V = spm_vol(brainmask_filename);
mask = spm_read_vols(V) > 0;
non_nan_mask = reshape(~any(isnan(pet_img)),V.dim);
non_zero_mask = reshape(~any(pet_img <= 0),V.dim);
mask = mask & non_nan_mask & non_zero_mask;
pet_img = pet_img(:,mask);

fprintf('Starting MA1 fit to %.0f voxels...',sum(mask(:)));
[Vt,intercept] = magia_fit_ma1(pet_img,input,frames,start_time,end_time);
fprintf(' Ready.\n');

Vt_img = zeros(size(mask));
intercept_img = Vt_img;

Vt_img(mask) = Vt;
intercept_img(mask) = intercept;

parametric_images = cell(2,1);

[~,filename] = fileparts(pet_filename);

V.dt = [spm_type('float32') 0];
V.pinfo = [inf inf inf]';

niftiname = fullfile(outputdir,[filename '_MA1_Vt_' int2str(start_time) '_' int2str(end_time) '.nii']);
V.fname = niftiname;
V.private.dat.fname = niftiname; 
spm_write_vol(V,Vt_img);

parametric_images{1} = niftiname;

niftiname = fullfile(outputdir,[filename '_MA1_intercept' int2str(start_time) '_' int2str(end_time) '.nii']);
V.fname = niftiname;
V.private.dat.fname = niftiname;  
spm_write_vol(V,intercept_img);

parametric_images{2} = niftiname;

end 
