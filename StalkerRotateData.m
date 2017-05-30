
[X, Y] = meshgrid(1:2000, 1:1000);
slantIndReal = [X(:) Y(:) ones(length(X(:)), 1) ones(length(X(:)), 1)]*TVoxFlat2World;

eastingGrid = reshape(slantIndReal(:,1), 1000, 2000);
northingGrid = reshape(slantIndReal(:,2), 1000, 2000);

[X, Z] = meshgrid(1:2000, 1:400);

%imRotBig = zeros(1000, 400, 2000);
imRotBig = zeros(1000, 400, 2000,'uint16');

s = size(data);

parfor i=1:1000
    if(mod(i, 100) == 0)
        fprintf('%d\n', i);
    end
    slantIndReal = [X(:) i*ones(length(X(:)), 1) Z(:) ones(length(X(:)), 1)]*TVoxFlat2World/TVox2World;
    slantInd = round(slantIndReal);
    offset = slantIndReal-slantInd-.5;
    
    slantNeighInd = slantInd;
    
    alpha = offset(:,1);
    slantNeighInd(:,1) = slantNeighInd(:,1)+2*(alpha>.5)-1;
    alpha = 1-abs(alpha);
    
    beta = offset(:,2);
    slantNeighInd(:,2) = slantNeighInd(:,2)+2*(beta>.5)-1;
    beta = 1-abs(beta);
    
    gamma = offset(:,3);
    slantNeighInd(:,3) = slantNeighInd(:,3)+2*(gamma>.5)-1;
    gamma = 1-abs(gamma);
    
    goodInds = slantInd(:,1) > 1 & slantInd(:,2) > 1 & slantInd(:,3) > 1 & slantInd(:,1) < s(:,3)-1 & slantInd(:,2) < s(:,1)-1 & slantInd(:,3) < s(:,2)-1;
    inds = (slantInd(:,1)-1)*s(1)*s(2) + (slantInd(:,3)-1)*s(1) + slantInd(:,2);
    indsNeighAlpha = (slantNeighInd(:,1)-1)*s(1)*s(2) + (slantInd(:,3)-1)*s(1) + slantInd(:,2);
    indsNeighBeta = (slantInd(:,1)-1)*s(1)*s(2) + (slantInd(:,3)-1)*s(1) + slantNeighInd(:,2);
    indsNeighGamma = (slantInd(:,1)-1)*s(1)*s(2) + (slantNeighInd(:,3)-1)*s(1) + slantInd(:,2);
    indsNeighAlphaBeta = (slantNeighInd(:,1)-1)*s(1)*s(2) + (slantInd(:,3)-1)*s(1) + slantNeighInd(:,2);
    indsNeighAlphaGamma = (slantNeighInd(:,1)-1)*s(1)*s(2) + (slantNeighInd(:,3)-1)*s(1) + slantInd(:,2);
    indsNeighBetaGamma = (slantInd(:,1)-1)*s(1)*s(2) + (slantNeighInd(:,3)-1)*s(1) + slantNeighInd(:,2);
    indsNeighAlphaBetaGamma = (slantNeighInd(:,1)-1)*s(1)*s(2) + (slantNeighInd(:,3)-1)*s(1) + slantNeighInd(:,2);
    
    imRot = zeros(400,2000);
    imRot(goodInds) = alpha(goodInds).*beta(goodInds).*gamma(goodInds).*data(inds(goodInds))+...
        (1-alpha(goodInds)).*beta(goodInds).*gamma(goodInds).*data(indsNeighAlpha(goodInds))+...
        alpha(goodInds).*(1-beta(goodInds)).*gamma(goodInds).*data(indsNeighBeta(goodInds))+...
        alpha(goodInds).*beta(goodInds).*(1-gamma(goodInds)).*data(indsNeighGamma(goodInds))+...
        (1-alpha(goodInds)).*(1-beta(goodInds)).*gamma(goodInds).*data(indsNeighAlphaBeta(goodInds))+...
        (1-alpha(goodInds)).*beta(goodInds).*(1-gamma(goodInds)).*data(indsNeighAlphaGamma(goodInds))+...
        alpha(goodInds).*(1-beta(goodInds)).*(1-gamma(goodInds)).*data(indsNeighBetaGamma(goodInds))+...
        (1-alpha(goodInds)).*(1-beta(goodInds)).*(1-gamma(goodInds)).*data(indsNeighAlphaBetaGamma(goodInds));
    f(3);imagesc(imRot, [0 .01]);
    pause(.01);
    
    imRotBig(i,:,:) = permute(imRot, [3 1 2])/h.data_scale_factor;
end

data = imRotBig;