//
//  PBGitStash.m
//  GitX
//
//  Created by Mathias Leppich on 8/1/13.
//
//

#import "PBGitStash.h"
#import "PBGitRef.h"
#import "PBGitCommit.h"
#import <git2.h>

@implementation PBGitStash

@synthesize index = _index;
@synthesize commit = _commit;
@synthesize message = _message;
@synthesize indexCommit = _indexCommit;
@synthesize ancesterCommit = _ancesterCommit;

-(id)initWithRepository:(PBGitRepository *)repo stashOID:(git_oid)stash_id index:(size_t)index message:(NSString *)message
{
    _index = index;
    _message = message;
    
    GTRepository * gtRepo = repo.gtRepo;
    NSError * error = nil;
	GTOID *stashOid = [GTOID oidWithGitOid:&stash_id];
    GTCommit * gtCommit = (GTCommit *)[gtRepo lookupObjectByOID:stashOid objectType:GTObjectTypeCommit error:&error];
    NSArray * parents = [gtCommit parents];
    GTCommit * gtIndexCommit = [parents objectAtIndex:1];
    GTCommit * gtAncestorCommit = [parents objectAtIndex:0];
    
	_commit = [[PBGitCommit alloc] initWithRepository:repo andCommit:gtCommit];
    _indexCommit = [[PBGitCommit alloc] initWithRepository:repo andCommit:gtIndexCommit];
    _ancesterCommit = [[PBGitCommit alloc] initWithRepository:repo andCommit:gtAncestorCommit];
    
    //NSLog(@" stash: %zd, %@, %@, %@",_index,[_commit shortName], [_ancesterCommit  shortName], [_indexCommit shortName]);
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"stash@{%zd}: %@", _index, _message];
}

-(PBGitRef *)ref
{
    NSString * refStr = [NSString stringWithFormat:@"refs/stash@{%zd}", _index];
    return [[PBGitRef alloc] initWithString:refStr];
}

@end